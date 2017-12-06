try:
    # For Python v.3 and later
    from urllib.request import urlopen
    from urllib.parse import quote
except ImportError:
    # For Python v.2
    from urllib2 import urlopen
    from urllib2 import quote
import json
import base64
import hmac
import hashlib
import time
username = 'Your dns lookup api username'
apiKey = 'Your dns lookup api api_key'
secret = 'Your dns lookup api secret_key'
type = '_all'
domains = [
    'google.com',
    'example.com',
    'whoisxmlapi.com',
    'twitter.com'
]
url = 'https://whoisxmlapi.com/whoisserver/DNSService?'
timestamp = 0
digest = 0

def generateDigest(username, timestamp, apikey, secret):
    digest = username + str(timestamp) + apikey
    hash = hmac.new(bytearray(secret.encode('utf-8')), bytearray(digest.encode('utf-8')), hashlib.md5)
    return quote(str(hash.hexdigest()))

def generateParameters(username, apikey, secret):
    timestamp = int(round(time.time() * 1000))
    digest = generateDigest(username, timestamp, apikey, secret)
    return timestamp, digest

def buildRequest(username, timestamp, digest, domain, type):
    requestString = "requestObject="
    data = {'u': username, 't': timestamp}
    dataJson = json.dumps(data)
    dataBase64 = base64.b64encode(bytearray(dataJson.encode('utf-8')))
    requestString += dataBase64.decode('utf-8')
    requestString += '&type='
    requestString += type
    requestString += "&digest="
    requestString += digest
    requestString += "&domainName="
    requestString += domain
    requestString += "&outputFormat=json"
    return requestString

def printResponse(response):
    responseJson = json.loads(response)
    print json.dumps(responseJson, indent=4, sort_keys=True)

def request(url, username, timestamp, digest, domain):
    request = buildRequest(username, timestamp, digest, domain, type)
    response = urlopen(url + request).read().decode('utf8')
    return response

timestamp, digest = generateParameters(username, apiKey, secret)

for domain in domains:
    response = request(url, username, timestamp, digest, domain)
    if "Request timeout" in response:
        timestamp, digest = generateParameters(username, apiKey, secret)
        response = request(url, username, timestamp, digest, domain)
    printResponse(response)
    print("---------------------------\n")