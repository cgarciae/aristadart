part of aristadart.server;

class VuforiaServices
{
    Future<VuforiaResponse> GetTarget (String id) async
    {
        return VuforiaServices.makeVuforiaRequest
        (
            Method.GET,
            '/targets/$id'
        );
    }
    static Future<VuforiaResponse> updateImage (String targetId, List<int> imageData)
    {
        return makeVuforiaRequest
        (
            Method.PUT,
            '/targets/$targetId',
            element: encryptElement
            (
                new VuforiaTargetRecord(), 
                imageData: imageData
            )
        );
    }
    
    static Future<VuforiaResponse> newImage (List<int> imageData, String metadata)
    {
        VuforiaTargetRecord obj = new VuforiaTargetRecord()
            ..width = 1.0;
            
        return makeVuforiaRequest
        (
            Method.POST,
            '/targets',
            element: encryptElement
            (
                obj, 
                imageData: imageData, 
                metadata: metadata
            )
        );
    }
    
    static VuforiaTargetRecord encryptElement (VuforiaTargetRecord element, {String metadata, List<int> imageData})
    {
        if (metadata != null)
        {
            element.name = metadata;
            element.application_metadata = crypto.CryptoUtils.bytesToBase64 (element.name.codeUnits);
        }
        
        if (imageData != null)
        {
            element.image = crypto.CryptoUtils.bytesToBase64 (imageData);
        }
        
        return element;
    }
    
    
    
    static Future<VuforiaResponse> makeVuforiaRequest (String verb, String path, {VuforiaTargetRecord element}) async
    {
        String body;
        String contentType;
        
        if (element != null)
        {
            body = encodeJson(element);
            contentType = ContType.applicationJson;
        }
        else
        {
            body = "";
            contentType = "";
        }
        
        print (body);
        
        String date = HttpDate.format(new DateTime.now());
        String accessKey = "8524c879ec19a80b912f989c33091af8ddd7ea8c";
       
        String signature = _createSignature
        (
            verb, path, body, 
            contentType, date
        );
        
        Map<String,String> headers = 
        {
            "Authorization" : "VWS ${accessKey}:${signature}",
            "Date" : date
        };
        
        if (notNullOrEmpty(contentType))
            headers.addAll({Header.contentType : contentType});
        
        var req = new http.Request
        (
            verb, 
            new Uri.https("vws.vuforia.com", path)
        );
         
        req.headers.addAll(headers);
        
        if (body != null && body.length > 0)
            req.body = body;
        
        http.StreamedResponse resp = await req.send();
        
        return streamResponseDecoded (VuforiaResponse, resp);
    }
    
    static String _createSignature (String verb, String path, String body, String contentType, String date) 
    {
          var hash = md5hash (body);
          
          var stringToSign = '$verb\n$hash\n$contentType\n$date\n$path';
          
          print(stringToSign);

          var server_secret_key = "a26b48430ac02696539b02957f0830572eaa4c6a";
          var signature = base64_HMAC_SHA1(server_secret_key, stringToSign);

        return signature;
    }
}