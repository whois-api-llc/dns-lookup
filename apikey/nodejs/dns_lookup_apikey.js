const crypto = require('crypto');
const https = require('https');
const queryString = require('querystring');

const url = 'https://whoisxmlapi.com/whoisserver/DNSService';
const username = 'Your dns lookup api username';
const apiKey = 'Your dns lookup api key';
const secretKey = 'Your dns lookup api secret key';
const type = '_all';

const domains = [
    'google.com',
    'example.com',
    'whoisxmlapi.com',
    'twitter.com'
];

for(var i in domains) {
    getDns(username, apiKey, secretKey, domains[i], type);
}

function getDns(username, apiKey, secretKey, domain, type)
{
    timestamp = (new Date).getTime();
    digest = generateDigest(username, timestamp, apiKey, secretKey);
    var requestString = buildRequest(username, timestamp, digest,domain,type);

    https.get(url + '?' + requestString, function (res) {
        const statusCode = res.statusCode;

        if (statusCode !== 200)
            console.log('Request failed: ' + statusCode);

        var rawData = '';

        res.on('data', function(chunk) {
            rawData += chunk;
        });

        res.on('end', function () {
            console.log(rawData);
        })

    }).on('error', function(e) {
        console.log("Error: " + e.message);
    });
}

function generateDigest(username, timestamp, apiKey, secretKey)
{
    var data = username + timestamp + apiKey;
    var hmac = crypto.createHmac('md5', secretKey);
    hmac.update(data);

    return hmac.digest('hex');
}

function buildRequest(username, timestamp, digest, domain, type)
{
    var data = {
        u: username,
        t: timestamp
    };

    var dataJson = JSON.stringify(data);
    var dataBase64 = Buffer.from(dataJson).toString('base64');

    var request = {
        requestObject: dataBase64,
        type: type,
        digest: digest,
        domainName: domain,
        outputFormat: 'json'
    };

    return queryString.stringify(request);
}