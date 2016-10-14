#!/usr/bin/perl -w

use strict;
use IO::Socket::INET;
use Getopt::Long qw(GetOptions);

my ($command);
GetOptions (
    'on'  => sub { $command = "on" },
    'off' => sub { $command = "off" },
    'shutdown' => sub { $command = "shutdown" },
) or die "Usage: $0 --command (on/off/shutdown)\n";

# auto-flush on socket
$| = 1;
 
# create a connecting socket
my $socket = new IO::Socket::INET (
    PeerHost => 'localhost',
    PeerPort => '7890',
    Proto => 'tcp',
);
die "cannot connect to the server $!\n" unless $socket;
print "Connected to the server\n";
 
# data to send to a server
my $req = 'hello world';
my $size = $socket->send( $command );
print "SEND: command \"$command\" ($size bytes)\n";
 
# notify server that request has been sent
shutdown($socket, 1);
 
# receive a response of up to 1024 characters from server
my $response = "";
$socket->recv($response, 1024);
print "RESULT: $response\n";
 
$socket->close();

1;
