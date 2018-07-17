$url = 'https://www.whoisxmlapi.com/whoisserver/DNSService'

$username = 'Your dns lookup api username'
$password = 'Your dns lookup api password'
$domainName = 'google.com'
$type = '_all'

$uri = $url`
     + '?type=' + [uri]::EscapeDataString($type)`
     + '&domainName=' + [uri]::EscapeDataString($domainName)`
     + '&username=' + [uri]::EscapeDataString($username)`
     + '&password=' + [uri]::EscapeDataString($password)

#######################
# Use an XML resource #
#######################

$j = Invoke-WebRequest -Uri $uri
echo $j.content

#######################
# Use a JSON resource #
#######################

$uri = $uri + '&outputFormat=json'

$j = Invoke-WebRequest -Uri $uri
echo $j.content | convertfrom-json | convertto-json -depth 10