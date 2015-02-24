part of aristadart.server;

//POST private/objetounity () -> ObjetoUnitySendResp
//PUT private/objetounity (json ObjetoUnity) -> Resp
//GET private/objetounity/:id () -> ObjetoUnitySendResp
//DELETE private/objetounity/:id () -> Resp
//POST|PUT private/objetounity/:id/userfile (form FormElement) ->
//ADMIN >> POST|PUT private/objetounity/:id/modelfile/:system (form FormElement) -> ObjetoUnitySendResp
//GET private/user/objetounitymodels () -> ObjetoUnitySendListResp


@app.Route('/private/localTarget', methods: const [app.POST])
@Encode()
newLocalTarget (@app.Attr() MongoDb dbConn) async
{   
    try
    {
        var obj = new LocalImageTargetSend()
            ..id = new ObjectId().toHexString()
            ..name = 'Nuevo Target Local'
            ..version = 0
            ..updatePending = false
            ..owner = (session["id"] as ObjectId).toHexString();
        
        await dbConn.insert
        (
            Col.localTarget, 
            obj
        );
        
        return new LocalImageTargetSendResp()
            ..obj = obj;
    }
    catch (e, stacktrace)
    {
        return new LocalImageTargetSendResp()
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route('/private/localTarget', methods: const [app.PUT])
@Encode()
putLocalTarget (@app.Attr() MongoDb dbConn, @Decode() LocalImageTarget obj) async
{
    print (encodeJson(obj));
    try 
    {
        await dbConn.update
        (
            Col.localTarget,
            where.id (StringToId(obj.id)),
            obj,
            override: false
        );
        
        return new Resp();
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route('/private/localTarget/:id', methods: const [app.GET])
@Encode()
Future<LocalImageTargetSendResp> getLocalTarget (@app.Attr() MongoDb dbConn, String id) async
{
    try
    {   
        LocalImageTargetSend obj = await dbConn.findOne
        (
            Col.localTarget,
            LocalImageTargetSend,
            where.id (StringToId (id))
        );
        
        if (obj == null)
            return new LocalImageTargetSendResp ()
                ..error = "Local Target not found";
        
        
        return new LocalImageTargetSendResp()
            ..obj = obj;
    }
    catch (e, stacktrace)
    {
        return new LocalImageTargetSendResp()
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route('/private/localTarget/:id', methods: const [app.DELETE])
@Encode()
deleteLocalTarget (@app.Attr() MongoDb dbConn, String id) async
{
    try
    {   
        await dbConn.remove
        (
            Col.localTarget,
            where.id (StringToId (id))
        );

        return new Resp();
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..error = e.toString() + stacktrace.toString();
    }
}


@app.Route('/private/localTarget/:id/userfile', methods: const [app.POST, app.PUT], allowMultipartRequest: true)
@Encode()
postOrPutLocalTargetImageFile (@app.Attr() MongoDb dbConn, @app.Body(app.FORM) Map form, String id) async
{
    try
    {
        IdResp fileIdResp;
        
        LocalImageTargetSendResp objResp = await getLocalTarget (dbConn, id);
        
        if (! objResp.success)
            return objResp;
        
        if (notNullOrEmpty (objResp.obj.imageId))
        {
            fileIdResp = await updateFile
            (
                dbConn, form, 
                objResp.obj.imageId
            );
        }
        else
        {
            fileIdResp = await newFile(dbConn, form);
        }
        
        
        if (! fileIdResp.success)
            return fileIdResp;
        
        await dbConn.update
        (
            Col.localTarget,
            where
                .id (StringToId (id)),
            modify
                .set('imageId', StringToId (fileIdResp.id))
                .set('updatePending', true)
        );
        
        return fileIdResp; 
    }
    catch (e, stacktrace)
    {
        return new IdResp()
            ..error = e.toString() + stacktrace.toString();
    }
}

Future saveOrUpdateImageFile (MongoDb dbConn, Map form, LocalImageTargetSend obj, String extension) async
{
    String fileId;
    
    if (extension == 'dat')
    {
        fileId = obj.datId;
    }
    else if (extension == 'xml')
    {
        fileId = obj.xmlId;
    }
    else
    {
        return new IdResp()
            ..error = "Invalid extension path variable: ${extension}";
    }
    
    IdResp idResp;
    
    if (fileId == null)
    {
        idResp = await newFile (dbConn, form);
    }
    else
    {
        idResp = await updateFile(dbConn, form, fileId);
    }
    
    if (! idResp.success)
        return idResp;
    
    if (extension == 'dat')
    {
        obj.datId = idResp.id;
        obj.updatedDat = true;
    }
    else if (extension == 'xml')
    {
        obj.xmlId = idResp.id;
        obj.updatedXml = true;
    }
    
    return idResp;   
}

@app.Route('/private/localTarget/:id/targetfile/:extension', methods: const [app.POST, app.PUT], allowMultipartRequest: true)
@Encode()
@Secure(ADMIN)
Future newOrUpdateLocalTargetImageFile (@app.Attr() MongoDb dbConn, @app.Body(app.FORM) Map form, String id, String extension) async
{
    try
    {
        LocalImageTargetSendResp objResp = await getLocalTarget(dbConn, id);
                
        if (! objResp.success)
            return objResp;
        
        IdResp idResp = await saveOrUpdateImageFile (dbConn, form, objResp.obj, extension);
        
        if (! idResp.success)
            return idResp;
        
        await dbConn.update
        (
            Col.localTarget,
            where.id (StringToId (id)),
            objResp.obj,
            override: false
        );
        
        return objResp;
        
    }
    catch (e, stacktrace)
    {
        return new LocalImageTargetSendResp()
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route ('/private/localTarget/:id/publish', methods: const [app.GET])
@Encode ()
@Secure (ADMIN)
Future publishLocalTarget (@app.Attr() MongoDb dbConn, String id) async
{
    try
    {
        LocalImageTargetSendResp objResp = await getLocalTarget(dbConn, id);
        
        if (objResp.failed)
            return objResp;
        
        if (! objResp.obj.updated)
            return new Resp ()
               ..error = "No se han actualizado todos los archivos del Local Target";
        
        await dbConn.update
        (
            Col.localTarget,
            where
                .id (StringToId (id)),
            modify
                .set('updatePending', false)
                .inc('version', 1)
                .set('updatedXml', false)
                .set('updatedDat', false)
                
        );
        
        return new Resp();
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..error = e.toString() + stacktrace.toString();
    }
}





@app.Route('/private/user/localTargets', methods: const [app.GET])
@Encode()
Future<LocalImageTargetSendListResp> userLocalTargets (@app.Attr() MongoDb dbConn) async
{
    try
    {  
        List<LocalImageTargetSend> objs = await dbConn.find
        (
            Col.localTarget,
            LocalImageTargetSend,
            where
                .eq('owner', userId)
        );

        return new LocalImageTargetSendListResp()
            ..objs = objs;
    }
    catch (e, stacktrace)
    {
        return new LocalImageTargetSendListResp()
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route ('/private/localTarget/pending', methods: const [app.GET], allowMultipartRequest: true)
@Encode ()
@Secure (ADMIN)
Future<LocalImageTargetSendListResp> getLocalTargetPending (@app.Attr() MongoDb dbConn) async
{
    try
    {
        List<LocalImageTargetSend> objs = await dbConn.find
        (
            Col.localTarget,
            LocalImageTargetSend,
            where
                .eq ('updatePending', true)
        );
        
        return new LocalImageTargetSendListResp()
            ..objs = objs;
    }
    catch (e, stacktrace)
    {
        return new LocalImageTargetSendListResp()
            ..error = e.toString() + stacktrace.toString();
    }
}