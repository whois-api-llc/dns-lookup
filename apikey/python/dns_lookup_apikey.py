try:
    # For Python v.3 and later
    from urllib.request import urlopen, pathname2url
    from urllib.parse import quote
except ImportError:
    # For Python v.2
    from urllib import pathname2url
    from urllib2 import urlopen, quote

import base64
import json
import hashlib
import hmac
import time

username = 'Your dns lookup api username'
api_key = 'Your dns lookup api key'
secret = 'Your dns lookup api secret key'
check_type = '_all'
domains = [
    'google.com',
    'example.com',
    'whoisxmlapi.com',
    'twitter.com'
]
url = 'https://whoisxmlapi.com/whoisserver/DNSService'


def generate_digest(req_user, req_timestamp, req_key, req_secret):
    res_digest = req_user + str(req_timestamp) + req_key

    res_hash = hmac.new(bytearray(req_secret.encode('utf-8')),
                        bytearray(res_digest.encode('utf-8')),
                        hashlib.md5)

    return quote(str(res_hash.hexdigest()))


def generate_parameters(req_user, req_key, req_secret):
    res_ts = int(round(time.time() * 1000))
    res_digest = generate_digest(req_user, res_ts, req_key, req_secret)

    return res_ts, res_digest


def build_request(req_user, req_timestamp, req_digest, req_domain, req_type):
    result = '?requestObject='

    data = {
        'u': req_user,
        't': req_timestamp
    }

    json_data = json.dumps(data)
    json_b64 = base64.b64encode(bytearray(json_data.encode('utf-8')))

    result += pathname2url(json_b64.decode('utf-8'))
    result += '&type='
    result += pathname2url(req_type)
    result += '&digest='
    result += pathname2url(req_digest)
    result += '&domainName='
    result += pathname2url(req_domain)
    result += '&outputFormat=json'

    return result


def print_response(txt):
    response_json = json.loads(txt)
    print(json.dumps(response_json, indent=4, sort_keys=True))


def request(req_url, req_user, req_timestamp,
            req_digest, req_domain, req_type):

    res_request = build_request(
                    req_user, req_timestamp, req_digest, req_domain, req_type)

    result = urlopen(req_url + res_request).read().decode('utf8')

    return result


timestamp, digest = generate_parameters(username, api_key, secret)

for domain in domains:
    response = request(url, username, timestamp, digest, domain, check_type)

    if 'Request timeout' in response:
        timestamp, digest = generate_parameters(username, api_key, secret)

        response = request(url, username, timestamp,
                           digest, domain, check_type)

    print_response(response)
    print('---------------------------\n')
