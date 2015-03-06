part of aristadart.server;

@app.Group('/file')
@Catch()
class FileServices
{
    @app.DefaultRoute(methods: const[app.POST], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<FileDb> NewOrUpdate (@app.Body(app.FORM) QueryMap form, 
                                @Decode(fromQueryParams: true) FileDb metadata,
                                [String id]) async
    {
        HttpBodyFileUpload file = FormToFileUpload(form);
            
        if (file == null || file.content == null || file.content.length == 0)
            throw new Exception("File is null or empty");
        
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
        
        
        metadata
            ..id = gridIn.id.toHexString()
            ..filename = file.filename
            ..type = file.contentType.value
            ..owner = (new User()
                ..id = userId);
        
        
        //Convert to map and clean null fields
        var metadataMap = cleanMap(db.encode(metadata));
        
        //Save metadata
        gridIn.metaData = metadataMap;
               
        //Wait till save finishes
        await gridIn.save();
        
        print ("1");
        
        return metadata;
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
    
    @app.Route ('/:id/metadata', methods: const [app.GET])
    @Private()
    @Encode()
    Future<FileDb> GetMetadata (String id) async
    {
        if (id == null)
            throw new Exception("No se pudo obtener metadata: id null");
        
        GridOut gridOut = await fs.findOne
        (
            where.id (StringToId(id))
        );
        
        
        if (gridOut == null)
            return new FileDb()
                ..error = "El archivo no existe";
        
        return db.decode(gridOut.metaData, FileDb);
        
    }
    
    @app.Route('/:id', methods: const[app.PUT], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<FileDb> Update (String id, @app.Body(app.FORM) Map form) async
    {
        
        FileDb metadata = await GetMetadata(id);
        DbObj obj = await Delete (id);
        FileDb fileDb = await NewOrUpdate(form, metadata, id);
        
        return fileDb;
    }
    
    @app.Route('/:id', methods: const[app.DELETE])
    @Private()
    @Encode()
    Future<DbObj> Delete (String id) async
    {
        await deleteFile(id);
             
        return new DbObj()
            ..id = id;
    }
    
    @app.Route('/all', methods: const[app.GET])
    @Private()
    @Encode()
    Future All (@app.QueryParam('type') String type) async
    {
        
        Stream<QueryMap> stream = fs.files.find
        (
            where.eq("metadata.owner._id", StringToId(userId))
        )
        .stream
        .map(MapToQueryMap);
        
        if (type != null)
            stream = stream.where((QueryMap file)
                    => (file.contentType as String).contains(type) || file.metadata.type == type);
        
        
        return stream.map((QueryMap file) => db.decode(file.metadata, FileDb)).toList();
    }
    
    @app.Route('/allImages', methods: const[app.GET])
    @Private()
    @Encode()
    Future AllImages () async
    {
        return All ('image');
    }
    
}