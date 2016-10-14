#!/usr/bin/perl -w

use strict;
use IO::Socket::INET;
use Device::SerialPort;
use Getopt::Long qw(GetOptions);

my %sys_commands = (
  'shutdown' => 1,
);
my %usb_commands = (
  'on' => 1,
  'off' => 1,
);
my $run = 1;  ## shutdown flag

my ($portname );
GetOptions (
    'usbportname|p=s' => \$portname,
) or die "Usage: $0 --usbportname Arduino_USB_Port_Device\n";

# creating a listening socket
my $socket = IO::Socket::INET->new(
    LocalAddr => 'localhost',
    LocalPort => '7890',
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1
) or die "cannot create socket $!\n";
print "SERVER started on port 7890\n";

# Set up the serial port
my $usbport = Device::SerialPort->new( $portname ) or
    die "Can't open $portname: $!\n";

$usbport->databits(8);
$usbport->baudrate(19200);
$usbport->parity("none");
$usbport->stopbits(1);
$usbport->dtr_active(0);
sleep 1;
print "Connected to $portname\n";

sleep 1;
print "Accepting client connections...\n\n";

while ( $run ) {

    # waiting for a new client connection
    my $client_socket = $socket->accept();
 
    # get information about a newly connected client
    my $client_address = $client_socket->peerhost();
    my $client_port = $client_socket->peerport();
    print "Connection from $client_address:$client_port\n";
 
    # read up to 1024 characters from the connected client
    my $command = "";
    $client_socket->recv( $command, 1024 );
    print "RECEIVED: command \"$command\"\n";

    unless ( $usb_commands{$command} || $sys_commands{$command} ) {
        response( $client_socket, 'Invalid command');
        next;
    }

    if ( $usb_commands{$command} ) {

        # send command from client to USB
        chomp( $command );
        my $aout = command( $usbport, $command );

        # write response data to the connected client
        response( $client_socket, $aout ? 'ok' : 'error' );

    } elsif ( $sys_commands{$command} ) {

        command( $usbport, "off" );  ## send off in case relay is on
        response( $client_socket, 'exit' );
        sleep 1;
        $run = 0;
    }
 
    # notify client that response has been sent
    shutdown($client_socket, 1);

}
 
print "Shutting down server\n";
$socket->close();

sub response {
    my $socket = shift;
    my $data = shift;

    my $sent = $socket->send( $data );
    print  "Responded \"$data\" to client\n\n";
}

sub command {
    my $usbport = shift;
    my $command = shift;

    my $aout = $usbport->write( "$command" );
    print "Sent command \"$command\" to $portname ($aout bytes)\n";

    return $aout;
}

1;