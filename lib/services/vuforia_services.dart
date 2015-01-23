part of arista_server;

addTarget (String path, List<int> data, String contentType)
{
    
}

createSignature (String body, String path, String date, {String type : "application/json", String verb : "POST"}) 
{
      var hash = md5hash (body);
      
      print (hash);
      
      var stringToSign = '$verb\n$hash\n$type\n$date\n$path';
      
      print(stringToSign);

      var server_secret_key = "a26b48430ac02696539b02957f0830572eaa4c6a";
      var signature = base64_HMAC_SHA1(server_secret_key, stringToSign);

    return signature;
}

String md5hash (String body)
{
    var md5 = new crypto.MD5()
        ..add(conv.UTF8.encode (body));
    
    return crypto.CryptoUtils.bytesToHex (md5.close());
}

String base64_HMAC_SHA1 (String hexKey, String stringToSign)
{
    
    var hmac = new crypto.HMAC(new crypto.SHA1(), conv.UTF8.encode (hexKey))
        ..add(conv.UTF8.encode (stringToSign));
    
    return crypto.CryptoUtils.bytesToBase64(hmac.close());
}
