part of aristadart.server;

@app.Group ('/vuforiaTargetRecord')
@Catch()
class VuforiaServices
{
    @app.Route ('/:id')
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
    
    static Future<VuforiaResponse> updateMetadata (String targetId, String metadata)
    {
        return makeVuforiaRequest
        (
            Method.PUT,
            '/targets/$targetId',
            element: encryptElement
            (
                new VuforiaTargetRecord(), 
                metadata: metadata
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
        String accessKey = "3dcd48a5b15c3aee70c4c73261de189a5118a195";
       
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
            headers.addAll({HeaderType.contentType : contentType});
        
        var req = new http.Request
        (
            verb, 
            new Uri.https("vws.vuforia.com", path)
        );
         
        req.headers.addAll(headers);
        
        if (body != null && body.length > 0)
            req.body = body;
        
        print (req.headers);
        print (req.body);
        
        http.StreamedResponse resp = await req.send();
        
        return streamResponseDecoded (VuforiaResponse, resp);
    }
    
    static String _createSignature (String verb, String path, String body, String contentType, String date) 
    {
          var hash = md5hash (body);
          
          var stringToSign = '$verb\n$hash\n$contentType\n$date\n$path';
          
          print(stringToSign);

          var server_secret_key = "e1a1ff6fbeda92abf82a636869b962f6313f7b98";
          var signature = base64_HMAC_SHA1(server_secret_key, stringToSign);

        return signature;
    }
}