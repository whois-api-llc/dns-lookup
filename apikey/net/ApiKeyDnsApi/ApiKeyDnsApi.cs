using System;
using System.Collections.Generic;
using System.Text;
using System.Security.Cryptography;
using System.Net;
using System.IO;
using Newtonsoft.Json;

/*
 * Target platform: .Net Framework 4.0
 * 
 * You need to install Newtonsoft JSON.NET
 *
 */

namespace ApiKeyDnsApi
{
    public static class ApiKeyDnsApi
    {
        private static void Main()
        {
            const string username = "Your dns lookup api username";
            const string apiKey = "Your dns lookup api key";
            const string secret = "Your dns lookup api secret key";
            const string url="https://whoisxmlapi.com/whoisserver/DNSService";
            const string type = "_all";

            string[] domains =
            {
                "google.com"
            };
            
            ApiSample.PerformRequest(username,apiKey,secret,url,domains,type);
        }
    }
    
    public static class ApiSample
    {
        public static void PerformRequest(
            string username,
            string apiKey,
            string secretKey,
            string url,
            IEnumerable<string> domains,
            string type
        )
        {
            var timestamp = GetTimeStamp();

            var digest = GenerateDigest(username, apiKey,secretKey,timestamp);

            foreach (var domain in domains)
            {
                try
                {
                    var request =
                        BuildRequest(username, timestamp, digest,domain,type);

                    var response = GetDnsData(url + request);

                    if (response.Contains("Request timeout"))
                    {
                        timestamp = GetTimeStamp();

                        digest = GenerateDigest(
                                    username, apiKey, secretKey, timestamp);

                        request = BuildRequest(
                                    username, timestamp, digest, domain,type);

                        response = GetDnsData(url + request);
                    }

                    PrintResponse(response);
                }
                catch (Exception)
                {
                    Console.WriteLine(
                        "Error occurred\r\nCannot get dns data for "+ domain);
                }
            }

            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
        }
        
        private static long GetTimeStamp()
        {
            return (long)(DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))
                                         .TotalMilliseconds);
        }
        
        private static string GenerateDigest(
            string username,
            string apiKey,
            string secretKey,
            long timestamp
        )
        {
            var data = username + timestamp + apiKey;
            var hmac = new HMACMD5(Encoding.UTF8.GetBytes(secretKey));

            var hex = BitConverter.ToString(
                        hmac.ComputeHash(Encoding.UTF8.GetBytes(data)));

            return hex.Replace("-", "").ToLower();
        }

        private static string BuildRequest(
            string username,
            long timestamp,
            string digest,
            string domain,
            string type
        )
        {
            var ud = new UserData
            {
                u = username,
                t = timestamp
            };

            var userData = JsonConvert.SerializeObject(ud,Formatting.None);
            var userDataBytes = Encoding.UTF8.GetBytes(userData);

            var userDataBase64 =
                Convert.ToBase64String(userDataBytes);

            var requestString = new StringBuilder();
            requestString.Append("?requestObject=");
            requestString.Append(Uri.EscapeDataString(userDataBase64));
            requestString.Append("&digest=");
            requestString.Append(Uri.EscapeDataString(digest));
            requestString.Append("&domainName=");
            requestString.Append(Uri.EscapeDataString(domain));
            requestString.Append("&type=");
            requestString.Append(Uri.EscapeDataString(type));
            requestString.Append("&outputFormat=json");

            return requestString.ToString();
        }

        private static string GetDnsData(string url)
        {
            var response = "";

            try
            {
                var wr = WebRequest.Create(url);
                var wp = wr.GetResponse();

                using (var data = wp.GetResponseStream())
                {
                    if (data == null)
                        return response;
                    using (var reader = new StreamReader(data))
                    {
                        response = reader.ReadToEnd();
                    }
                }
                wp.Close();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                throw new Exception(e.Message);
            }

            return response;
        }
        
        private static void PrintResponse(string response)
        {
            dynamic responseObject = JsonConvert.DeserializeObject(response);

            if (responseObject.DNSData != null)
            {
                var dnsData = responseObject.DNSData;
                Console.Write(dnsData);
                Console.WriteLine("--------------------------------");
                return;
            }

            Console.WriteLine(response);
        }
    }

    internal class UserData
    {
        public string u { get; set; }
        public long t { get; set; }
    }
}