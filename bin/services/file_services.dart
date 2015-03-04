part of aristadart.server;

@app.Group('/file')
class FileServices
{
    @app.DefaultRoute(methods: const[app.POST], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<FileDb> NewOrUpdate (@app.Body(app.FORM) Map form, [String id]) async
    {
        try
        {
            HttpBodyFileUpload file = form.values
                    .where((value) => value is HttpBodyFileUpload).first;
            
            if (file == null || file.content == null || file.content.length == 0)
                return new FileDb()
                    ..error = "File is null or empty";
            
            //Define input from uploaded file
            var input = new Stream.fromIterable([file.content]);
            
            //Create gridFS file
            var gridIn = fs.createFile(input, file.filename)
                ..contentType = file.contentType.value;
            
            //Maybe set id
            if (id != null)
            {
                gridIn.id = StringToId(id);
            }
            
            //Convert metadata and save id
            FileDb fileDb = decode(app.request.queryParams, FileDb);
            fileDb.id = gridIn.id.toHexString();
            
            //Convert to map and clean null fields
            var metadata = cleanMap(db.encode(fileDb));
            
            //Save metadata
            gridIn.metaData = metadata;
                   
            //Wait till save finishes
            await gridIn.save();
            
            return fileDb;
        }
        catch (e, s)
        {
            return new FileDb()
                ..error = "$e $s";
        }
    }
    
    @app.Route ('/:id', methods: const [app.GET])
    Future Get (String id) async
    {
        try
        {
            GridOut gridOut = await fs.findOne
            (
                where.id (StringToId(id))
            );
            
            if (gridOut == null)
                return encodeJson (new Resp()
                    ..error = "El archivo no existe");
            
            return new shelf.Response.ok
            (
                getData (gridOut), 
                headers: { "Content-Type": gridOut.contentType }
            );
        }
        catch (e, s)
        {
            return {"error" : "$e $s"};
        }
    }
    
    @app.Route('/:id', methods: const[app.PUT], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<FileDb> Update (String id, @app.Body(app.FORM) Map form) async
    {
        try
        {
            DbObj obj = await Delete (id);
            
            if (obj.failed)
                return new FileDb()
                    ..error = obj.error;
            
            FileDb fileDb = await NewOrUpdate(form, id);
            
            return fileDb;
            
        }
        catch (e, s)
        {
            return new FileDb()
                ..error = "$e $s";
        }
    }
    
    @app.Route('/:id', methods: const[app.DELETE])
    @Private()
    @Encode()
    Future<DbObj> Delete (String id) async
    {
        try
        {
             await deleteFile(id);
             
             return new DbObj()
                ..id = id;
        }
        catch (e, s)
        {
            return new DbObj()
                ..error = "$e $s";
        }
    }
}

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
        
        await deleteFile (fileID);
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