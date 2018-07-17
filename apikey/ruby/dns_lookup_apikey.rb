require 'base64'
require 'erb'
require 'json'
require 'net/http'
require 'openssl'
require 'uri'

domains = %w[
  google.com
  whoisxmlapi.com
  twitter.com
]

check_type = '_all'
url = 'https://whoisxmlapi.com/whoisserver/DNSService'
username = 'Your dns lookup api username'
api_key = 'Your dns lookup api key'
secret = 'Your dns lookup api secret key'

def generate_digest(username, timestamp, api_key, secret)
  digest = username + timestamp.to_s + api_key
  OpenSSL::HMAC.hexdigest(OpenSSL::Digest::MD5.new, secret, digest)
end

def build_request(username, timestamp, digest, domain, check_type)
  data = {
    u: username,
    t: timestamp
  }
  '?requestObject=' + ERB::Util.url_encode(Base64.encode64(data.to_json)) +
    '&type=' + ERB::Util.url_encode(check_type) +
    '&digest=' + ERB::Util.url_encode(digest) +
    '&domainName=' + ERB::Util.url_encode(domain) +
    '&outputFormat=json'
end

def print_response(response)
  response_hash = JSON.parse(response)
  puts JSON.pretty_generate(response_hash)
end

timestamp = (Time.now.to_f * 1000).to_i
digest = generate_digest(username, timestamp, api_key, secret)

domains.each do |domain|
  request_string =
    build_request(username, timestamp, digest, domain, check_type)

  response = Net::HTTP.get(URI.parse(url + request_string))

  if response.include? 'Request timeout'
    timestamp = (Time.now.to_f * 1000).to_i
    digest = generate_digest(username, timestamp, api_key, secret)

    request_string =
      build_request(username, timestamp, digest, domain, check_type)

    response = Net::HTTP.get(URI.parse(url + request_string))
  end

  print_response(response)
  puts "--------------------------------\n"
end