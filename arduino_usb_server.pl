#!/usr/bin/perl -w

use strict;
use IO::Socket::INET;
use Device::SerialPort;
use Getopt::Long qw(GetOptions Configure);
use Pod::Usage qw(pod2usage);

my %sys_commands = (
  'shutdown' => 1,
);
my %usb_commands = (
  'on' => 1,
  'off' => 1,
);
my $run = 1;  ## shutdown flag

Configure( 'auto_help' );
my %options;
GetOptions ( \%options,
    'usbportname|u=s',
    'port|p=i',
) || pod2usage(1);

pod2usage(1) unless ( $options{usbportname} );

my $localport = $options{port} || 7890;
my $rs232port = $options{usbportname};
my $rs232baud = 19200;  ## Doesn't like higher speeds

# creating a listening socket
my $socket = IO::Socket::INET->new(
    LocalAddr => 'localhost',
    LocalPort => $localport,
    Proto     => 'tcp',
    Listen    => 5,
    Reuse     => 1
) or die "cannot create socket $!\n";
print "SERVER started on port $localport\n";

# Set up the serial port
my $usbport = Device::SerialPort->new( $rs232port ) or
    die "Can't open $rs232port: $!\n";

$usbport->databits( 8 );
$usbport->baudrate( $rs232baud );
$usbport->parity( "none" );
$usbport->stopbits( 1 );
$usbport->dtr_active( 0 );
sleep 1;
print "Connected to $rs232port at $rs232baud bps\n";

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
    print "Sent command \"$command\" to $rs232port ($aout bytes)\n";

    return $aout;
}

__END__

=head1 NAME

arduino_usb_server - Arduino Relay Switch via USB serial Server. Controlled by arduino_usb_client.

=head1 SYNOPSIS

  arduino_usb_server.pl [options]

  Options:
    --help          Brief help message
    --usbportname   Arduino USB serial port [REQUIRED]
    --port          Local TCP port for server to listen on [7890]

=cut
