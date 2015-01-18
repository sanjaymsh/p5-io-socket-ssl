use strict;
use warnings;
use IO::Socket::SSL;
use IO::Socket::SSL;

my $addr = shift(@ARGV) || '127.0.0.1:8443';
my $cl = IO::Socket::SSL->new(
    PeerAddr => $addr,
    SSL_cert_file => 'certs/client.pem',
    SSL_key_file => 'certs/client.pem',
    SSL_ca_file => 'certs/root-cert.pem',
    SSL_verify_mode => SSL_VERIFY_PEER,
    SSL_verifycn_scheme => 'none',
    SSL_verify_callback => sub {
	my ($valid,$store,$str,$err,$cert,$depth) = @_;
	warn "[$depth] $valid - $str\n";
	return 1;
	return $valid;
    },
) or die "$!,$SSL_ERROR";
print $cl->get_sslversion."/".$cl->get_cipher."\n";

