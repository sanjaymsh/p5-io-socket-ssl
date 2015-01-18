#!/usr/bin/perl
# Create some sample certificates. Move them to certs/ to use with other sample code.

use strict;
use warnings;
use IO::Socket::SSL::Utils 0.031;

my @root = CERT_create(
    purpose => 'sslCA',
    subject => { CN => 'root' }
);
PEM_cert2file($root[0],'root-cert.pem');
PEM_key2file($root[1],'root-key.pem');

my @chain = CERT_create(
    purpose => 'sslCA',
    subject => { CN => 'chain' },
    issuer_cert => $root[0],
    issuer_key  => $root[1],
);
PEM_cert2file($chain[0],'chain-cert.pem');
PEM_key2file($chain[1],'chain-key.pem');

my @server = CERT_create(
    purpose => 'server',
    subject => { CN => 'server' },
    issuer_cert => $chain[0],
    issuer_key  => $chain[1],
);
PEM_cert2file($server[0],'server-cert.pem');
PEM_key2file($server[1],'server-key.pem');


my @client = CERT_create(
    purpose => 'client',
    subject => { CN => 'client' },
    issuer_cert => $chain[0],
    issuer_key  => $chain[1],
);
PEM_cert2file($client[0],'client-cert.pem');
PEM_key2file($client[1],'client-key.pem');

open(my $fh,'>','client.pem') or die $!;
print $fh PEM_cert2string($client[0]).PEM_cert2string($chain[0]).PEM_key2string($client[1]);
open($fh,'>','server.pem') or die $!;
print $fh PEM_cert2string($server[0]).PEM_cert2string($chain[0]).PEM_key2string($server[1]);

