try:
    from urllib.request import urlopen
except ImportError:
    from urllib2 import urlopen

domain = 'example.com'
password = 'Your dns lookup api password'
username = 'Your dns lookup api username'

url = 'http://www.whoisxmlapi.com/whoisserver/DNSService?type=_all'\
    + '&domainName=' +domain + '&username=' +username + '&password=' +password

print(urlopen(url).read().decode('utf8'))