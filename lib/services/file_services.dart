part of arista_server;

@app.Route("/public/file/:fileID", methods: const [app.GET])
getFile(@app.Attr() MongoDb dbConn, String fileID)
{
    GridFS gridFS = new GridFS (dbConn.innerConn);
    ObjectId objID = StringToId(fileID);
            
    return gridFS.findOne(where.id(objID)).then((GridOut gridOut)
    {
        if (gridOut == null)
        {
            return {'success' : false};
        }
        
        return new shelf.Response.ok 
        (
            getData (gridOut), 
            headers: { "Content-Type": gridOut.contentType }
        );
    });
}

@app.Route("/private/file", methods: const [app.POST], allowMultipartRequest: true)
@Encode()
newFile(@app.Attr() MongoDb dbConn, @app.Body(app.FORM) Map form)
{
    HttpBodyFileUpload file = form ['file'];
    var gridFS = new GridFS (dbConn.innerConn);
    
    var input = new Stream.fromIterable([file.content]);
    
    var gridIn = gridFS.createFile(input, file.filename);
    
    gridIn.contentType = file.contentType.value;
            
    return gridIn.save().then((res)
            => new IdResp()
                ..success = true
                ..id = gridIn.id.toHexString());
}

@app.Route("/private/file/:fileID", methods: const [app.DELETE])
@Encode()
Future<Resp> deleteFile(@app.Attr() MongoDb dbConn, String fileID)
{
    var fs = new GridFS (dbConn.innerConn);

    return deleteFiles (fs, where.id(new ObjectId.fromHexString(fileID))).then((_)
    {
        return new Resp()
            ..success = true;
    });
}

@app.Route("/private/file/:fileID", methods: const [app.PUT], allowMultipartRequest: true)
@Encode()
Future<Resp> updateFile(@app.Attr() MongoDb dbConn, @app.Body(app.FORM) Map form, String fileID)
{
    HttpBodyFileUpload file = form ['file'];
    var gridFS = new GridFS (dbConn.innerConn);
    var input = new Stream.fromIterable([file.content]);
        
    var gridIn = gridFS.createFile(input, file.filename)
        ..id = StringToId (fileID)
        ..contentType = file.contentType.value;
    
    return deleteFile(dbConn, fileID).then((Resp resp)
    {
        return gridIn.save();
    })
    .then((res)
    {
        return new IdResp()
            ..success = true
            ..id = gridIn.id.toHexString();
    });
}