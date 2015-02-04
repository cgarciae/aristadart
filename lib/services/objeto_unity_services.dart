part of arista_server;


@app.Route('/private/objetounity', methods: const [app.POST])
@Encode()
newObjetoUnity (@app.Attr() MongoDb dbConn) async
{
    try
    {
        var obj = new ObjetoUnitySend()
            ..id = new ObjectId().toHexString()
            ..name = 'Nuevo Modelo'
            ..version = 0
            ..updatePending = false
            ..owner = (session["id"] as ObjectId).toHexString();
        
        await dbConn.insert (Col.objetoUnity, obj);
        
        return new ObjetoUnitySendResp()
            ..success = true
            ..obj = obj;
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..success = false
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route('/private/objetounity', methods: const [app.PUT])
@Encode()
putObjetoUnity (@app.Attr() MongoDb dbConn, @Decode() ObjetoUnity obj) async
{
    print (encodeJson(obj));
    try 
    {
        await dbConn.update
        (
            Col.objetoUnity,
            where.id (StringToId(obj.id)),
            obj,
            override: false
        );
        
        return new Resp()
            ..success = true;
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..success = false
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route('/private/objetounity/:id', methods: const [app.GET])
@Encode()
getObjetoUnity (@app.Attr() MongoDb dbConn, String id) async
{
    try
    {   
        ObjetoUnitySend obj = await dbConn.findOne
        (
            Col.objetoUnity,
            ObjetoUnitySend,
            where.id(StringToId(id))
        );
        
        if (obj == null)
            return new Resp()
                ..success = false
                ..error = "Objeto Unity not found";
        
        
        return new ObjetoUnitySendResp()
            ..success = true
            ..obj = obj;
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..success = false
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route('/private/objetounity/:id', methods: const [app.DELETE])
@Encode()
deleteObjetoUnity (@app.Attr() MongoDb dbConn, String id) async
{
    try
    {   
        await dbConn.remove
        (
            Col.objetoUnity,
            where.id(StringToId(id))
        );

        return new Resp()
            ..success = true;
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..success = false
            ..error = e.toString() + stacktrace.toString();
    }
}


@app.Route('/private/objetounity/:id/userfile', methods: const [app.POST], allowMultipartRequest: true)
@Encode()
postObjetoUnityUserFile (@app.Attr() MongoDb dbConn, @app.Body(app.FORM) Map form, String id) async
{
    try
    {
        Resp resp = await newFile(dbConn, form);
        IdResp idResp = resp as IdResp;
        
        if (! resp.success || idResp == null)
            return resp;
        
        
        await dbConn.update
        (
            Col.objetoUnity,
            where.id (StringToId (id)),
            {
                r'$set' : {
                    'userFileId' : StringToId (idResp.id),
                    'updatePending' : true
                }
            }
        );
        
        return idResp;    
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..success = false
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route('/private/objetounity/:id/userfile/:fileId', methods: const [app.PUT], allowMultipartRequest: true)
@Encode()
putObjetoUnityUserFile (@app.Attr() MongoDb dbConn, @app.Body(app.FORM) Map form, String id, String fileId) async
{
    try
    {
        var resp = await updateFile(dbConn, form, fileId);
        
        await dbConn.update
        (
            Col.objetoUnity,
            where.id (StringToId (id)),
            {
                r'$set' : 
                {
                    'updatePending' : true
                }
            }
        );
        
        return resp;
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..success = false
            ..error = e.toString() + stacktrace.toString();
    }
}

Future saveOrUpdateModelFile (MongoDb dbConn, Map form, ObjetoUnitySend obj, String system) async
{
    String fileId;
    
    if (system == 'android')
    {
        fileId = obj.modelIdAndroid;
    }
    else if (system == 'ios')
    {
        fileId = obj.modelIdIOS;
    }
    else if (system == 'windows')
    {
        fileId = obj.modelIdWindows;
    }
    else if (system == 'mac')
    {
        fileId = obj.modelIdMAC;
    }
    else
    {
        return new Resp()
            ..success = false
            ..error = "Invalid system path variable: ${system}";
    }
    
    Resp resp;
    IdResp idResp;
    
    if (fileId == null)
    {
        resp = await newFile (dbConn, form);
    }
    else
    {
        resp = await updateFile(dbConn, form, fileId);
    }
    
    if (resp is IdResp && resp.success)
    {
        idResp = resp;
    }
    else
    {
        return resp;
    }
    
    if (system == 'android')
    {
        obj.modelIdAndroid = idResp.id;
    }
    else if (system == 'ios')
    {
        obj.modelIdIOS = idResp.id;
    }
    else if (system == 'windows')
    {
        obj.modelIdWindows = idResp.id;
    }
    else if (system == 'mac')
    {
        obj.modelIdMAC = idResp.id;
    }
    
    return idResp;   
}

@app.Route('/private/objetounity/:id/modelfile/:system', methods: const [app.POST, app.PUT], allowMultipartRequest: true)
@Encode()
@Secure(ADMIN)
Future newOrUpdateObjetoUnityModelFile (@app.Attr() MongoDb dbConn, @app.Body(app.FORM) Map form, String id, String system) async
{
    try
    {
        ObjetoUnitySendResp objResp = await getObjetoUnity(dbConn, id);
                
        if (! objResp.success)
            return objResp;
        
        ObjetoUnitySend obj = objResp.obj;
        
        Resp resp = await saveOrUpdateModelFile (dbConn, form, obj, system);
        
        if (! resp.success)
            return resp;
        
        await dbConn.update
        (
            Col.objetoUnity,
            where.id (StringToId (id)),
            obj
        );
        
        return objResp;
        
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..success = false
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route('/private/user/objetounitymodels', methods: const [app.GET])
@Encode()
userModels (@app.Attr() MongoDb dbConn) async
{
    try
    {  
        List<ObjetoUnitySend> objs = await dbConn.find
        (
            Col.objetoUnity,
            ObjetoUnitySend,
            where.eq('owner', userId)
        );

        return new ObjetoUnitySendListResp()
            ..success = true
            ..objs = objs;
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..success = false
            ..error = e.toString() + stacktrace.toString();
    }
}