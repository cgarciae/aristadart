part of aristadart.server;

@app.Route ('/testQuery')
testQuery (@app.QueryParam('algo') String algo, @app.QueryParam('mas') String mas) => "$algo $mas";

@app.Route ('/testVuforiaImage', methods: const[app.POST], allowMultipartRequest: true)
@Encode()
Future<VuforiaResponse> testVuforiaImage (@app.Body(app.FORM) Map form) async
{
    HttpBodyFileUpload file = FormToFileUpload(form);
    
    return VuforiaServices.newImage(file.content, newId());
}

@app.Route ('/updateVuforiaImage/:id', methods: const[app.PUT], allowMultipartRequest: true)
@Encode()
Future<VuforiaResponse> updateVuforiaImage (String id, @app.Body(app.FORM) Map form) async
{
    
    HttpBodyFileUpload file = FormToFileUpload(form);
    
    return VuforiaServices.updateImage(id, file.content);
}

@app.Route ('/testOverride')
@Encode()
testOverride () async
{
    
    var id = newId();
    
    VuforiaResponse resp = new VuforiaResponse()
        ..result_code = "Success"
        ..id = id
        ..target_record = (new VuforiaTargetRecord()
            ..name = "Garcia");
    
    var col = 'testVuforia';
    
    await db.insert(col, resp);
    
    var delta = new VuforiaResponse()
        ..target_record = (new VuforiaTargetRecord()
                ..width = 2);
        
    
    await db.update
    (
        col,
        where.id(StringToId(id)),
        delta,
        override: false
    );
    
    return db.findOne (col, VuforiaResponse, where.id(StringToId(id)));
}

@Encode()
@app.Route ('/testErro1/:n')
@Catch()
@Private()
testError1 (int n) async
{
    print ("hola");
    var resp = await testError2(n);
    return resp;
}

@app.Route ('/testErro2')
@Encode()
testError2 (int n) async
{
    await db.find(Col.cloudTarget, Resp);
    
    if (n != 1)
        throw new Exception ("invalid id");
    
    return new BoolResp()
        ..value = true;
}

@app.Route ('/testPrivate')
@Private()
testPrivate () => "funciona";

@app.Route("/test")
@Encode()
gridFSTest(@app.Attr() MongoDb dbConn)
{
    var gridFS = new GridFS (dbConn.innerConn);
    var input = new File ('../web/test/file.txt').openRead();
    var gridIn = gridFS.createFile (input, 'file.txt');
    
    return gridIn.save()
            .then((res) => gridFS.getFile('file.txt'))
            .then((GridOut gridOut) => gridOut.writeToFilename('../web/test/file_out.txt'))
            .then((_) =>
                new IdResp()
                    ..id = gridIn.id.toHexString()
            );
}

@app.Route("/test/files")
gridFSTestFiles(@app.Attr() MongoDb dbConn)
{
    var gridFS = new GridFS (dbConn.innerConn);

    return gridFS.chunks.find().toList().then((List<Map> list)
    {
        list.forEach (print);
        
        return list.toString();
    });
}

@app.Route("/test/send/:fileID")
sendImage(@app.Attr() MongoDb dbConn, String fileID)
{
    GridFS gridFS = new GridFS (dbConn.innerConn);
    ObjectId objID = StringToId(fileID);
            
    return gridFS.findOne(where.id(objID)).then((GridOut gridOut)
    {
        if (gridOut == null)
        {
            return {'success' : false};
        }
        
        return getData(gridOut).toList().then(flatten).then((List<int> list)
        { 
            var base64Image = crypto.CryptoUtils.bytesToBase64 (list);
            var metadata = crypto.CryptoUtils.bytesToBase64 ("Funciona!".codeUnits);
            
            String body = conv.JSON.encode
            ({
                "name": "test1",
                "width" : 1.0,
                "image" : base64Image,
                "application_metadata" : metadata
            });
            
            return makeVuforiaRequest("POST", "/targets", body, "application/json").send()
            
            .then((http.StreamedResponse resp)
            {
                print ("Request headers ${resp.request.headers}");
                print ("Response headers ${resp.headers}");
                
                return resp.stream.toList();
            })
            .then(flatten).then((List<int> list)
            {   
                return bytesToJSON (list);
            });
            
        });
    });
}

@app.Route ('/test/async')
@Encode()
testAsync (@app.Attr() MongoDb dbConn) async
{
    var res = await panelInfo (dbConn);
    
    print (res);
    
    return res;
}

@app.Route('/esteban', methods: const [app.POST])
@Encode()
testEsteban (@app.Attr() MongoDb dbConn, @Decode() User usuario) async
{ 
    usuario.id = new ObjectId().toHexString();
    await dbConn.insert(Col.user, usuario);
    
    return new IdResp()
        ..id = usuario.id;
}

@app.Route("/testH")
@Encode()
Future testH(@app.Attr() MongoDb dbConn) async
{
     var a = new TA()
        ..nombre = "A"
        ..id = new ObjectId().toHexString();
     
     var b = new TA()
             ..nombre = "B"
             ..id = new ObjectId().toHexString();
     
     a.ref = new TA()
                ..id = b.id;
     
     await dbConn.insertAll("TA", [a, b]);
     
     TA a2 = await dbConn.findOne("TA", TA, where.id(StringToId(a.id)));
     
     print (encodeJson(a2));
     
     a2.ref = await dbConn.findOne("TA", TA, where.id(StringToId(a2.ref.id)));
     return a2;
}


