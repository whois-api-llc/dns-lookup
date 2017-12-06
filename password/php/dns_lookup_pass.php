<?php

$domain = 'example.com';
$password = 'Your dns lookup api password';
$username = 'Your dns lookup api username';

$url ="http://www.whoisxmlapi.com/whoisserver/DNSService?domainName={$domain}"
     ."&username={$username}&password={$password}&type=A,SOA,TXT";

print(file_get_contents($url));