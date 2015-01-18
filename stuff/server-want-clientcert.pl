use strict;
use IO::Socket::SSL;

# Server
my $srv = IO::Socket::SSL->new( 
    LocalAddr => $ARGV[0] || '127.0.0.1:8443',
    Listen => 10, 
    Reuse => 1,
    SSL_cert_file => 'certs/server.pem',
    SSL_key_file => 'certs/server.pem',
    SSL_ca_file => 'certs/root-cert.pem',
    SSL_client_ca_file => 'certs/root-cert.pem', # since 2.009, no effect in earlier versions
    SSL_verify_mode => SSL_VERIFY_PEER,
    SSL_verify_callback => sub {
	my ($valid,$store,$str,$err,$cert,$depth) = @_;
	warn "[$depth] err=".Net::SSLeay::X509_verify_cert_error_string($err) if $err;
	warn "[$depth] $valid - $str\n";
	return 1; # $valid;
    },
) or die "$!,$SSL_ERROR";

while (1) {
    my $cl = $srv->accept or do {
	warn "accept failed: $!, $SSL_ERROR";
	next;
    };
    print "client cert: ".$cl->peer_certificate('subject')."\n";
    
    my $hdr = '';
    while (<$cl>) {
	$hdr .= $_;
	last if $_ eq "\r\n" || $_ eq "\n";
    }
    print "HTTP/1.0 200 ok\r\nContent-type: text/plain\r\n\r\n".
	"SSL: ".$cl->get_sslversion()."/".$cl->get_cipher()."\n".
	"-----\n".
	$hdr;
    close($cl);
}
