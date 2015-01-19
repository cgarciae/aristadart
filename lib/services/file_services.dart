part of arista_server;

@app.Route("/public/get/file/:fileID")
getFile(@app.Attr() MongoDb dbConn, String fileID)
{
    GridFS gridFS = new GridFS (dbConn.innerConn);
    ObjectId objID = StringToId(fileID);
            
    return gridFS.findOne(where.id(objID)).then((GridOut gridOut)
    {        
        var stream = getData (gridOut);
        
        return new shelf.Response.ok (stream, headers: { "Content-Type": gridOut.contentType }); // You'll have to set the content-type of the file
    });
}

@app.Route("/private/new/file", methods: const [app.POST], allowMultipartRequest: true)
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

@app.Route("/private/delete/file/:fileID")
@Encode()
testDeleteFile(@app.Attr() MongoDb dbConn, String fileID)
{
    var fs = new GridFS (dbConn.innerConn);

    return deleteFiles(fs, where.id(new ObjectId.fromHexString(fileID))).then((_)
        => new Resp()
            ..success = true);
}