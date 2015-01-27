part of arista_server;

Future<Map> uploadImageToVuforia (String method, String path, List<int> imageData, String metadata)
{
    var base64Image = crypto.CryptoUtils.bytesToBase64 (imageData);
    var metadataBytes = crypto.CryptoUtils.bytesToBase64 (metadata.codeUnits);
    
    String body = conv.JSON.encode
    ({
        "name": metadata,
        "width" : 1.0,
        "image" : base64Image,
        "application_metadata" : metadataBytes
    });
    
    return makeVuforiaRequest(method, path, body, ContType.applicationJson).send()
    
    .then((http.StreamedResponse resp)
    {
        print ("Request headers ${resp.request.headers}");
        print ("Response headers ${resp.headers}");
        
        return resp.stream.toList();
    })
    .then (flatten).then((List<int> list)
    {   
        return bytesToJSON (list);
    });
}

Future<Map> streamResponseToJSON (http.StreamedResponse resp)
{
    
    return resp.stream.toList()
            
    .then (flatten)
    
    .then ((List<int> list)
    {
        print (list.runtimeType);
        
        return bytesToJSON (list);
    });
}

@app.Route("/private/new/vuforiaimage/:eventoID", methods: const [app.POST], allowMultipartRequest: true)
@Encode()
newImageVuforia(@app.Attr() MongoDb dbConn, @app.Body(app.FORM) Map form, String eventoID)
{
    String imageID;
    
    HttpBodyFileUpload file = form ['file'];
    var gridFS = new GridFS (dbConn.innerConn);
    var input = new Stream.fromIterable([file.content]);
    var gridIn = gridFS.createFile(input, file.filename)
        ..contentType = file.contentType.value;
    
            
    return gridIn.save()
            
    .then((_) => uploadImageToVuforia (Method.POST, "/targets", file.content, eventoID))
            
    .then (MapToQueryMap).then((QueryMap map)
    {
        print (map);
        
        if (map.result_code == "TargetCreated")
        {
            imageID = gridIn.id.toHexString();
            String targetID = map.target_id;
            
            return createRecoTarget (dbConn, eventoID, imageID, targetID);
        }
        else
        {
            return deleteFile (dbConn, imageID)
                    
            .then((_) => new Resp()
                ..success = false
                ..error = map.result_code
            );
        }
    });
}

@app.Route("/private/update/vuforiaimage/:eventoID", methods: const [app.POST], allowMultipartRequest: true)
@Encode()
updateImageVuforia(@app.Attr() MongoDb dbConn, @app.Body(app.FORM) Map form, String eventoID)
{
    String targetID;
    String imageID;
    String cloudRecoID;
    
    HttpBodyFileUpload file = form ['file'];
    
    return dbConn.findOne
    (
        Col.evento,
        Evento,
        where.id (StringToId (eventoID))
    )
    .then ((Evento evento)
    {
        if (evento == null)
            return new Resp()
                ..success = false
                ..error = "Evento not found";
        
        eventoID = evento.id;
        cloudRecoID = evento.cloudRecoTargetId;
        
        return dbConn.findOne
        (
            Col.recoTarget,
            AristaCloudRecoTargetComplete, 
            where.id (StringToId (cloudRecoID))
        );
    })
    .then ((resp)
    {
        if (resp is Resp)
            return resp;
        
        var reco = resp as AristaCloudRecoTargetComplete;
        
        if (reco == null)
            return new Resp ()
                ..success = false
                ..error = "Not found";
        
        targetID = reco.targetId;
        imageID = reco.imageId;
        
        return updateFile (dbConn, form, imageID);
    })
    .then ((Resp resp)
    {
        if (! resp.success)
            return resp;
        
        return uploadImageToVuforia (Method.PUT, "/targets/${targetID}", file.content, eventoID);
    })
    .then((dynamic resp)
    {
        if (resp is Resp)
           return resp;
        
        var map = MapToQueryMap (resp);
        
        if (map.result_code == "TargetCreated" || map.result_code == "Success")
        {
            return new Resp()
                ..success = true;
        }
        else
        {
            return new Resp()
                ..success = false
                ..error = map.result_code;
        }        
    });
}

@app.Route("/private/neworupdate/vuforiaimage/:eventoID", methods: const [app.POST], allowMultipartRequest: true)
@Encode()
newOrUpdateImageVuforia(@app.Attr() MongoDb dbConn, @app.Body(app.FORM) Map form, String eventoID)
{
    return dbConn.findOne
    (
        Col.evento,
        Evento,
        where.id(StringToId(eventoID))
    )
    .then((Evento evento)
    {
        if (evento == null)
            return new Resp()
                ..success = false
                ..error = "Evento not found";
        
        if (evento.cloudRecoTargetId == null || evento.cloudRecoTargetId == "")
            return newImageVuforia(dbConn, form, eventoID);
        
        
        return updateImageVuforia(dbConn, form, eventoID);
    });
}

@app.Route("/public/get/vuforiatarget/:eventoID")
@Encode()
Future<Resp> getVuforiaTarget(@app.Attr() MongoDb dbConn, String eventoID)
{
    return dbConn.findOne
    (
        Col.evento,
        Evento,
        where.id (StringToId (eventoID))
    )
    .then((Evento evento)
    {
        if (evento == null)
            return new Resp()
                ..success = false
                ..error = "Evento not found";
        
        return dbConn.findOne
        (
            Col.recoTarget, 
            AristaCloudRecoTargetComplete,
            where.id (StringToId (evento.cloudRecoTargetId))
        );
    })
    .then (ifDidntFail ((AristaCloudRecoTargetComplete reco)
    {
        return makeVuforiaRequest(Method.GET, "/targets/${reco.targetId}", "", "")
                
        .send().then (streamResponseToJSON).then (MapToQueryMap);
    }))
    .then (ifDidntFail ((QueryMap map)
    {
        if (map.result_code == "Success")
            return new MapResp()
                ..success = true
                ..map = map;
        
        return new Resp()
            ..success = false
            ..error = map.result_code;
    }));
    
}

Future<RecoTargetResp> createRecoTarget (MongoDb dbConn, String eventoID, String imageID, String targetID)
{
    var recoTarget = new AristaCloudRecoTargetComplete()
        ..imageId = imageID
        ..targetId = targetID
        ..id = new ObjectId().toHexString();
        
    return dbConn.insert (Col.recoTarget, recoTarget)
    
    .then((_) => dbConn.update 
    (
        Col.evento, 
        where.id (StringToId (eventoID)), 
        modify.set ('cloudRecoTargetId', recoTarget.id))
    )
    .then((_) => new RecoTargetResp()
        ..success = true
        ..recoTargetID = recoTarget.id
        ..imageID = imageID
        ..targetID = targetID);
}

createSignature (String verb, String path, String body, String contentType, String date) 
{
      var hash = md5hash (body);
      
      print (hash);
      
      var stringToSign = '$verb\n$hash\n$contentType\n$date\n$path';
      
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

http.Request makeVuforiaRequest (String verb, String path, String body, String contentType)
{
    String date = HttpDate.format(new DateTime.now());
    String accessKey = "8524c879ec19a80b912f989c33091af8ddd7ea8c";
   
    String signature = createSignature (verb, path, body, contentType, date);
    
    Map<String,String> headers = 
    {
        "Authorization" : "VWS ${accessKey}:${signature}",
        "Content-Type" : contentType,
        "Date" : date
    };
    
    var req = new http.Request (verb, new Uri.https("vws.vuforia.com", path))
        ..headers.addAll(headers);
    
    print ("Body length ${body.length}");
    
    if (body != null && body.length > 0)
        req.body = body;
    
    return req;
}


