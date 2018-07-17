require 'erb'
require 'json'
require 'net/https'
require 'uri'

########################
# Fill in your details #
########################
username = 'Your dns lookup api username'
password = 'Your dns lookup api password'

domains = %w[
  google.com
  whoisxmlapi.com
  twitter.com
]

url = 'https://whoisxmlapi.com/whoisserver/DNSService'
type = 'TXT'

def build_request(username, password, type, domain)
  'type=' + ERB::Util.url_encode(type) +
    '&username=' + ERB::Util.url_encode(username) +
    '&password=' + ERB::Util.url_encode(password) +
    '&outputFormat=json' +
    '&domainName=' + ERB::Util.url_encode(domain)
end

def print_response(response)
  response_hash = JSON.parse(response)
  puts JSON.pretty_generate(response_hash)
end

domains.each do |domain|
  request_string = build_request(username, password, type, domain)
  response = Net::HTTP.get(URI.parse(url + '?' + request_string))
  print_response(response)
  puts "--------------------------------\n"
end