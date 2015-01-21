part of arista_server;

addTarget (String path, List<int> data, String contentType)
{
    
}

String hashMd5Hex (body) => body;

createStringToSign (String body) 
{
    
    var content = [65, 66, 67];
      var md5 = new crypto.MD5();
      md5.add(content);

      var verb = 'GET';
      var hash = crypto.CryptoUtils.bytesToHex(md5.close());
      
      var type = 'text/plain';
      var date = HttpDate.format(new DateTime.now());
      var path = '/request/path';
      var stringToSign = '$verb\n$hash\n$type\n$date\n$path';
      print(stringToSign);
      print('');

      var key = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
      var hmac = new crypto.HMAC(new crypto.SHA1(), key);
      
      hmac.add(content);
      print(crypto.CryptoUtils.bytesToBase64(hmac.close()));
      
      
    http.post("");
    
    var req = new http.Request ("POST", new Uri (path: "www.algo.com/algo"));
    
    new DateTime.now();
    
    var newLine = '\n';

    var stringToSign =

        req.method + newLine +
        hashMd5Hex(body) + newLine +
        req.headers + newLine +
        req.headers.date.toString() + newLine +
        req.uri.path;

    return stringToSign;
}