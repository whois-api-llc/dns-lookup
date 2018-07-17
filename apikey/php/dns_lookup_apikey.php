<?php

$username = 'Your dns lookup api username';
$apiKey = 'Your dns lookup api key';
$secret = 'Your dns lookup api secret key';

$url = 'https://whoisxmlapi.com/whoisserver/DNSService';
$timestamp = null;

$domains = array(
    'google.com',
    'example.com',
    'whoisxmlapi.com',
    'twitter.com',
);

$type = '_all';
$digest = null;

generateParameters($timestamp, $digest, $username, $apiKey, $secret);

foreach ($domains as $domain) {
    $response = request($url, $username, $timestamp, $digest, $domain, $type);
    if (strpos($response, 'Request timeout') !== false) {
        generateParameters($timestamp, $digest, $username, $apiKey, $secret);
        $response = request($url, $username,$timestamp,$digest,$domain,$type);
    }
    printResponse($response);
    echo '----------------------------' . "\n";
}

function generateParameters(&$timestamp, &$digest, $username, $apiKey,$secret)
{
    $timestamp = round(microtime(true) * 1000);
    $digest = generateDigest($username, $timestamp, $apiKey, $secret);
}

function request($url, $username, $timestamp, $digest, $domain, $type)
{
    $requestString = buildRequest($username,$timestamp,$digest,$domain,$type);
    return file_get_contents($url . '?' . $requestString);
}

function printResponse($response)
{
    echo $response;
}
function generateDigest($username, $timestamp, $apiKey, $secretKey)
{
    $digest = $username . $timestamp . $apiKey;
    $hash = hash_hmac('md5', $digest, $secretKey);

    return urlencode($hash);
}

function buildRequest($username, $timestamp, $digest, $domain, $type)
{
    $requestString = 'requestObject=';
    $request = array(
        'u' => $username,
        't' => $timestamp
    );
    $requestJson = json_encode($request);
    $requestBase64 = base64_encode($requestJson);
    $requestString .= urlencode($requestBase64);
    $requestString .= '&type=' . urlencode($type);
    $requestString .= '&digest=' . $digest;
    $requestString .= '&domainName=' . urlencode($domain);
    $requestString .= '&outputFormat=json';

    return $requestString;
}