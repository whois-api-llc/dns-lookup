var http = require('https');
var querystring = require('querystring');

var domain = 'example.com';
var username = 'Your dns lookup api username';
var password = 'Your dns lookup api password';
var checkType = '_all';

var url = 'https://www.whoisxmlapi.com/whoisserver/DNSService';

var params = {
    type: checkType,
    domainName: domain,
    username: username,
    password: password
};

url = url + '?' + querystring.stringify(params);

http.get(url, function(response) {
    var str = '';
    response.on('data', function(chunk) {
        str += chunk;
    });
    response.on('end', function() {
        console.log(str);
    });
}).end();