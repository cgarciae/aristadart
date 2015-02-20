part of arista_server;

@app.Route("/public/file/:fileID", methods: const [app.GET])
getFile(@app.Attr() MongoDb dbConn, String fileID) async
{
    GridFS gridFS = new GridFS (dbConn.innerConn);
    ObjectId objID = StringToId(fileID);
       
    GridOut gridOut = await gridFS.findOne (where.id(objID));
    
    if (gridOut == null)
    {
        return {'success' : false};
    }
    
    return new shelf.Response.ok 
    (
        getData (gridOut), 
        headers: { "Content-Type": gridOut.contentType }
    );
}

@app.Route("/private/file", methods: const [app.POST], allowMultipartRequest: true)
@Encode()
Future<IdResp> newFile(@app.Attr() MongoDb dbConn, @app.Body(app.FORM) Map form) async
{
    try
    {
        HttpBodyFileUpload file = form ['file'];
        
        if (file == null || file.content == null || file.content.length == 0)
            return new IdResp()
                ..error = "Empty File";
        
        var gridFS = new GridFS (dbConn.innerConn);
        
        var input = new Stream.fromIterable([file.content]);
        
        var gridIn = gridFS.createFile(input, file.filename)
            ..contentType = file.contentType.value;
                
        await gridIn.save();
        
        return new IdResp()
            ..id = gridIn.id.toHexString();
    }
    catch (e, stacktrace)
    {
        return new IdResp()
            ..error = "SERVER ERROR: " + e.toString() + stacktrace.toString();
    }
}

@app.Route("/private/file/:fileID", methods: const [app.DELETE])
@Encode()
Future<Resp> deleteFile(@app.Attr() MongoDb dbConn, String fileID) async
{
    var fs = new GridFS (dbConn.innerConn);

    await deleteFiles (fs, where.id(new ObjectId.fromHexString(fileID)));
    
    return new Resp();
}

@app.Route("/private/file/:fileID", methods: const [app.PUT], allowMultipartRequest: true)
@Encode()
Future<IdResp> updateFile(@app.Attr() MongoDb dbConn, @app.Body(app.FORM) Map form, String fileID) async
{
    try
    {
        HttpBodyFileUpload file = form ['file'];
        
        if (file == null || file.content == null || file.content.length == 0)
                return new Resp ()
                    ..error = "Empty File";
        
        var gridFS = new GridFS (dbConn.innerConn);
        var input = new Stream.fromIterable([file.content]);
            
        var gridIn = gridFS.createFile(input, file.filename)
            ..id = StringToId (fileID)
            ..contentType = file.contentType.value;
        
        await deleteFile (dbConn, fileID);
        await gridIn.save();
    
        return new IdResp()
            ..id = gridIn.id.toHexString();
    }
    catch (e, stacktrace)
    {
        return new IdResp()
            ..error = e.toString() + stacktrace.toString();
    }
}