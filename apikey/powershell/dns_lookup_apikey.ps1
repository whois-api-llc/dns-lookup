$url = 'https://www.whoisxmlapi.com/whoisserver/DNSService'

$domain = 'google.com'
$type = '_all';

$username = 'Your dns lookup api username'
$key = 'Your dns lookup api key'
$secret = 'Your dns lookup api secret key'

$time = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
$req=[Text.Encoding]::UTF8.GetBytes("{`"t`":$($time),`"u`":`"$($username)`"}")
$req = [Convert]::ToBase64String($req)

$data = $username + $time + $key
$hmac = New-Object System.Security.Cryptography.HMACMD5
$hmac.key = [Text.Encoding]::UTF8.GetBytes($secret)
$hash = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($data))
$digest = [BitConverter]::ToString($hash).Replace('-', '').ToLower()

$uri = $url`
     + '?type=' + [uri]::EscapeDataString($type)`
     + '&requestObject=' + [uri]::EscapeDataString($req)`
     + '&digest=' + [uri]::EscapeDataString($digest)`
     + '&domainName=' + [uri]::EscapeDataString($domain)

echo (Invoke-WebRequest -Uri $uri).Content