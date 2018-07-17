try:
    from urllib.request import urlopen, pathname2url
except ImportError:
    from urllib import pathname2url
    from urllib2 import urlopen

domain = 'example.com'
username = 'Your dns lookup api username'
password = 'Your dns lookup api password'
checkType = '_all'

url = 'http://www.whoisxmlapi.com/whoisserver/DNSService?'\
    + 'type=' + pathname2url(checkType)\
    + '&domainName=' + pathname2url(domain)\
    + '&username=' + pathname2url(username)\
    + '&password=' + pathname2url(password)

print(urlopen(url).read().decode('utf8'))
