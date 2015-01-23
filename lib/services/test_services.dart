part of arista_server;

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
        
        return getData(gridOut).toList().then((List<List<int>> listList)
        { 
            List<int> list = listList.expand (F.identity).toList();
            
            print ("Original List : ${list.toString()}");
            
            var base64Image = crypto.CryptoUtils.bytesToBase64 (list);
            
            print ("Base64 : ${base64Image.toString()}");

            var metadata = crypto.CryptoUtils.bytesToBase64 ("Funciona!".codeUnits);
            
            print ("Metadata base64 : ${"Funciona!".codeUnits}");
            
            Map json = 
            {
                "name": "test1",
                "width" : 1.0,
                "image" : base64Image,
                "application_metadata" : metadata
            };
            
            var body = conv.JSON.encode (json);
            var authority = "vws.vuforia.com";
            var path = "/targets";
            var date = HttpDate.format(new DateTime.now());
            
            String signature = createSignature (body, path, date);
            
            var accessKey = "8524c879ec19a80b912f989c33091af8ddd7ea8c";
            
            Map<String,String> headers = 
            {
                "Authorization" : "VWS ${accessKey}:${signature}",
                "Content-Type" : "application/json",
                "Date" : date
            };
            
            http.Request req = new http.Request ("POST", new Uri.https(authority, path));
            req.headers.addAll(headers);
            req.body = body;
            
            return req.send().then((http.StreamedResponse resp)
            {
                print ("Request headers ${resp.request.headers}");
                print ("Response headers ${resp.headers}");
                
                return resp.stream.toList();
            })
            .then((List<List<int>> listList)
            {
                list = listList.expand(F.identity).toList();
                
                return conv.JSON.decode (conv.UTF8.decode (list));
            });
            
        });
    });
}
