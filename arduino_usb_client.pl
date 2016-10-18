#!/usr/bin/perl -w

use strict;
use IO::Socket::INET;
use Getopt::Long qw(GetOptions Configure);
use Pod::Usage qw(pod2usage);

Configure( 'auto_help' );
my ($command);
my %options;
GetOptions ( \%options,
    'on'  => sub { $command = "on" },
    'off' => sub { $command = "off" },
    'shutdown' => sub { $command = "shutdown" },
    'port|p=i',
) || pod2usage(1);

pod2usage(1) unless ( $command );

my $serverport = $options{port} || 7890;

# auto-flush on socket
$| = 1;
 
# create a connecting socket
my $socket = new IO::Socket::INET (
    PeerHost => 'localhost',
    PeerPort => $serverport,
    Proto    => 'tcp',
);
die "Can't connect to the server: $!\n" unless $socket;
print "Connected to the server on port $serverport\n";
 
# data to send to a server
my $size = $socket->send( $command );
print "SEND: command \"$command\" ($size bytes)\n";
 
# notify server that request has been sent
shutdown($socket, 1);
 
# receive a response of up to 1024 characters from server
my $response = "";
$socket->recv($response, 1024);
print "RESULT: $response\n";
 
$socket->close();

__END__

=head1 NAME

arduino_usb_client - Arduino Relay Switch via Serial Server

=head1 SYNOPSIS

  arduino_usb_client.pl [options]

  Options:
    --help      Brief help message
    --on        Turn relay on connected Arduino on
    --off       Turn relay on connected Arduino off
    --shutdown  Shut down server
    --port      Local TCP port that server is listening on [7890]

=cut
