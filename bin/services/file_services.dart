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
            HttpBodyFileUpload file = FormToFileUpload(form);
            
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