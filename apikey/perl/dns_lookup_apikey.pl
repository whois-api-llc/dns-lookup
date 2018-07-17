use LWP::Protocol::https;                   # From CPAN
use LWP::Simple;                            # From CPAN
use JSON qw( decode_json encode_json );     # From CPAN
use Time::HiRes qw( time );                 # From CPAN
use Digest::HMAC_MD5 qw( hmac_md5_hex );    # From CPAN
use URI::Escape qw( uri_escape );           # From CPAN
use MIME::Base64 qw( encode_base64 );

use strict;
use warnings;

my @domains = (
    'google.com',
    'example.com',
    'whoisxmlapi.com',
    'twitter.com'
);
my $type = '_all';

my $url = 'https://whoisxmlapi.com/whoisserver/DNSService';
my $username = 'Your dns lookup api username';
my $apiKey = 'Your dns lookup api key';
my $secret = 'Your dns lookup api secret key';

my $timestamp = int((time * 1000 + 0.5));
my $digest = generateDigest($username, $timestamp, $apiKey, $secret);

foreach my $domain (@domains) {
    my $requstString = buildRequest(
        $username, $timestamp, $digest, $domain, $type);

    my $response = get($url . '?' . $requstString);

    if (index($response, 'Request timeout')) {
        $timestamp = int((time * 1000 + 0.5));
        $digest = generateDigest($username, $timestamp, $apiKey, $secret);
        $requstString = buildRequest(
            $username, $timestamp, $digest, $domain, $type);

        $response = get($url . '?' . $requstString);
    }

    printResponse($response);
}

sub generateDigest
{
    my ($req_username, $req_timestamp, $req_key, $req_secret) = @_;

    my $res_digest = $req_username . $req_timestamp . $req_key;
    my $hash = hmac_md5_hex($res_digest, $req_secret);

    return uri_escape($hash);
}

sub buildRequest
{
    my ($req_username, $req_timestamp,$req_digest,$req_domain,$req_type) = @_;
    my $result = 'requestObject=';

    my %request =(
        'u' => $req_username,
        't' => $req_timestamp
    );

    my $requestJson = encode_json(\%request);
    my $requestBase64 = uri_escape(encode_base64($requestJson));

    $result .= uri_escape($requestBase64);
    $result .= '&type=' . uri_escape($req_type);
    $result .= '&digest=' . uri_escape($req_digest);
    $result .= '&domainName=' . uri_escape($req_domain);
    $result .= '&outputFormat=json';

    return $result;
}

sub printResponse
{
    my ($response) = @_;
    print $response;
    print "---------------------------------------\n";
}