<?php

$domain = 'example.com';
$username = 'Your dns lookup api username';
$password = 'Your dns lookup api password';
$type = 'A,SOA,TXT';

$url
   = 'https://www.whoisxmlapi.com/whoisserver/DNSService'
   . '?domainName=' . urlencode($domain)
   . '&username=' . urlencode($username)
   . '&password=' . urlencode($password)
   . '&type=' . urlencode($type);

print(file_get_contents($url) . PHP_EOL);