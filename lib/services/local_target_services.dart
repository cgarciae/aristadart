part of arista_server;

//POST private/objetounity () -> ObjetoUnitySendResp
//PUT private/objetounity (json ObjetoUnity) -> Resp
//GET private/objetounity/:id () -> ObjetoUnitySendResp
//DELETE private/objetounity/:id () -> Resp
//POST|PUT private/objetounity/:id/userfile (form FormElement) ->
//ADMIN >> POST|PUT private/objetounity/:id/modelfile/:system (form FormElement) -> ObjetoUnitySendResp
//GET private/user/objetounitymodels () -> ObjetoUnitySendListResp


@app.Route('/private/localtarget', methods: const [app.POST])
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

@app.Route('/private/localtarget', methods: const [app.PUT])
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

@app.Route('/private/localtarget/:id', methods: const [app.GET])
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

@app.Route('/private/localtarget/:id', methods: const [app.DELETE])
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


@app.Route('/private/localtarget/:id/userfile', methods: const [app.POST, app.PUT], allowMultipartRequest: true)
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

@app.Route('/private/localtarget/:id/targetfile/:extension', methods: const [app.POST, app.PUT], allowMultipartRequest: true)
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

newOrUpdateLocalTargetScreenshot (MongoDb dbConn, Map form, LocalImageTargetSend obj) async
{
    try
    {
        IdResp idResp;
        
        if (notNullOrEmpty (obj.imageId))
        {
            idResp = await updateFile(dbConn, form, obj.imageId);
        }
        else
        {
            idResp = await newFile(dbConn, form);
        }
        
        
        if (! idResp.success)
            return idResp;
        
        obj.imageId =  idResp.id;
        
        await dbConn.update
        (
            Col.localTarget,
            where.id (StringToId (obj.id)), 
            modify.set ('imageId', StringToId (idResp.id))
        );
        
        return idResp;
    }
    catch (e, stacktrace)
    {
        return new IdResp()
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route ('/private/localtarget/:id/screenshot', methods: const [app.POST, app.PUT], allowMultipartRequest: true)
@Encode ()
@Secure (ADMIN)
Future<IdResp> newOrUpdateLocalTargetScreenshotRoute (@app.Attr() MongoDb dbConn, @app.Body(app.FORM) Map form, String id) async
{
    try
    {
        IdResp idResp;
        LocalImageTargetSendResp objResp = await getLocalTarget (dbConn, id);
                
        if (! objResp.success)
            return objResp;
       
        
        //Updates screenshotId, return IdResp
        return newOrUpdateLocalTargetScreenshot (dbConn, form, objResp.obj);
    }
    catch (e, stacktrace)
    {
        return new IdResp()
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route ('/private/localtarget/:id/publish', methods: const [app.GET])
@Encode ()
@Secure (ADMIN)
Future publishLocalTarget (@app.Attr() MongoDb dbConn, String id) async
{
    try
    {
        LocalImageTargetSendResp objResp = await getLocalTarget(dbConn, id);
        
        if (! objResp.success)
            return objResp;
        
        if (! objResp.obj.updatedAll)
            return new Resp ()
               ..error = "No se han actualizado todos los archivos del Local Target";
        
        await dbConn.update
        (
            Col.localTarget,
            where.id (StringToId (id)),
            modify
                .set('updatePending', false)
                .inc('version', 1)
        );
        
        return new Resp();
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..error = e.toString() + stacktrace.toString();
    }
}





@app.Route('/private/user/localtargets', methods: const [app.GET])
@Encode()
Future<LocalTargetSendListResp> userLocalTargets (@app.Attr() MongoDb dbConn) async
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

        return new LocalTargetSendListResp()
            ..objs = objs;
    }
    catch (e, stacktrace)
    {
        return new LocalTargetSendListResp()
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route ('/private/localtarget/pending', methods: const [app.GET], allowMultipartRequest: true)
@Encode ()
@Secure (ADMIN)
Future<LocalTargetSendListResp> getLocalTargetPending (@app.Attr() MongoDb dbConn) async
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
        
        return new LocalTargetSendListResp()
            ..objs = objs;
    }
    catch (e, stacktrace)
    {
        return new LocalTargetSendListResp()
            ..error = e.toString() + stacktrace.toString();
    }
}