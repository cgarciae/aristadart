part of aristadart.server;

//POST private/objetounity () -> ObjetoUnitySendResp
//PUT private/objetounity (json ObjetoUnity) -> Resp
//GET private/objetounity/:id () -> ObjetoUnitySendResp
//DELETE private/objetounity/:id () -> Resp
//POST|PUT private/objetounity/:id/userfile (form FormElement) ->
//ADMIN >> POST|PUT private/objetounity/:id/modelfile/:system (form FormElement) -> ObjetoUnitySendResp
//GET private/user/objetounitymodels () -> ObjetoUnitySendListResp


@app.Group('/${Col.objetoUnity}')
@Catch()
class ObjetoUnityServices extends MongoDbService<ObjetoUnity>
{
    ObjetoUnityServices() : super (Col.objetoUnity);
    
    @app.DefaultRoute (methods: const [app.POST])
    @Private()
    @Encode()
    Future<ObjetoUnity> New () async
    {
        ObjetoUnity obj = new ObjetoUnity()
            ..name = "Nuevo Modelo"
            ..version = 0
            ..updatePending = false
            ..updatedAndroid = false
            ..updatedIOS = false
            ..updatedWindows = false
            ..updatedMAC= false
            ..id = newId()     
            ..owner = (new User()
                ..id = userId);
        
        await insert(obj);
        
        return obj;
    }
    
    @app.Route ('/:id', methods: const [app.GET])
    @Encode()
    Future<ObjetoUnity> Get (String id) async
    {
        ObjetoUnity obj = await findOne
        (
            where.id(StringToId(id))
        );
        
        if (obj == null)
            throw new Exception("Objecto Unity no encontrado");
        
        return obj;
    }
    
    @app.Route ('/:id', methods: const [app.PUT])
    @Private()
    @Encode()
    Future<ObjetoUnity> Update (String id, @Decode() ObjetoUnity delta) async
    {
        await db.update
        (
            collectionName,
            where.id(StringToId(id)),
            getModifierBuilder(delta)
        );
        
        return Get(id);
    }
    
    @app.Route ('/:id', methods: const [app.PUT])
    @Private()
    @Encode()
    Future<DbObj> Delete (String id) async
    {
        await remove
        (
            where.id(StringToId(id))
        );
        
        return new DbObj()
            ..id = id;
    }
    
    @app.Route ('/:id/userFile', methods: const [app.POST, app.PUT], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<ObjetoUnity> NewOrUpdateUserFile (
                                    String id, 
                                    @app.Body(app.FORM) QueryMap form, 
                                    @Decode(fromQueryParams: true) FileDb metadata) async
    {
        //Variables
        FileDb userFile;
        
        //Obtener objeto unity
        ObjetoUnity obj = await Get (id);
        
        //Revisar si userFile existe
        if (obj.userFile != null)
        {
            //Update
            userFile = await new FileServices().Update (obj.userFile.id, form);
        }
        else
        {
            //New
            userFile = await new FileServices().NewOrUpdate(form, metadata);
        }
        
        //Crear cambios
        ObjetoUnity delta = new ObjetoUnity()
            ..updatePending = true
            ..userFile = (new FileDb()
                ..id = userFile.id);
        
        //Guardar cambios
        await Update (id, delta);
       
        
        return Get(id);
    }
    
    /**
     * [id] es el id del ObjetoUnity en Mongo
     * [form] es el FORM representado en un `QueryMap` del request
     * [metadata] son los parametros query del request representados en un FileDb
     * 
     * [metadata] como minimo debe especificar el campo `system` con el sistema operativo corresponde
     * al modelo. Ver [SystemType] para saber las opciones.
     */
    @app.Route ('/:id/model', methods: const [app.POST, app.PUT], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<ObjetoUnity> NewOrUpdateModel (
                                    String id, 
                                    @app.Body(app.FORM) QueryMap form, 
                                    @Decode(fromQueryParams: true) FileDb metadata) async {
        
        if (metadata.system == null)
            throw new Exception("No se especifico el sistema en el metadata. Ver SystemType");
        
        //Variables
        FileDb modelFile;
        
        //Obtener objeto unity
        ObjetoUnity obj = await Get (id);
        
        FileDb actualFile = getModel(obj, metadata.system);
        
        //Revisar si userFile existe
        if (actualFile != null)
        {
            //Update
            modelFile = await new FileServices().Update (actualFile.id, form);
        }
        else
        {
            //New
            modelFile = await new FileServices().NewOrUpdate(form, metadata);
        }
        
        //Crear cambios
        ObjetoUnity delta = getDelta (modelFile.id, metadata.system);
        
        //Guardar cambios
        await Update (id, delta);
       
        return Get(id);
    }
    
    FileDb getModel (ObjetoUnity obj, String system)
    {
        switch (system)
        {
            case SystemType.ios:
                return obj.ios;
            case SystemType.osx:
                return obj.osx;
            case SystemType.android:
                return obj.android;
            case SystemType.windows:
                return obj.windows;
            default:
                throw new Exception("Tipo de sistema incorrecto: $system");
        }
    }
    
    ObjetoUnity getDelta (String fileId, String system)
    {
        FileDb newFile = new FileDb()
            ..id = fileId;
        
        switch (system)
        {
            case SystemType.ios:
                return new ObjetoUnity()
                ..ios = newFile
                ..iosUpdated = true;
            case SystemType.osx:
                return new ObjetoUnity()
                ..osx = newFile
                ..osxUpdated = true;
            case SystemType.android:
                return new ObjetoUnity()
                ..android = newFile
                ..androidUpdated = true;
            case SystemType.windows:
                return new ObjetoUnity()
                ..windows = newFile
                ..windowsUpdated = true;
            default:
                throw new Exception("Tipo de sistema incorrecto: $system");
        }
    }
    
    @app.Route ('/:id/publish', methods: const [app.PUT])
    @Private()
    @Encode()
    Future<ObjetoUnity> Publish (String id) async
    {
        //Obtener el objeto
        ObjetoUnity obj = await Get (id);
        
        //Avisar error si el objeto no esta propiamente actualizado
        if (! (obj.active && obj.updated))
            throw new Exception("No se puede publicar ObjetoUnity. Estado Actual: ${encodeJson(obj)}");
        
        //Crear cambios
        ObjetoUnity delta = new ObjetoUnity()
            ..version += 1
            ..updatePending = false;
        
        //Guardar
        await db.update
        (
            collectionName,
            where.id(StringToId(id)),
            getModifierBuilder(delta)
        );
        
        //Retornar objeto modificado
        return Get (id);
    }
}

Future<IdResp> newOrUpdateScreenshot (MongoDb dbConn, Map form, ObjetoUnitySend obj) async
{
    try
    {
        Resp resp;
        IdResp idResp;
        
        if (notNullOrEmpty (obj.screenshotId))
        {
            resp = await updateFile(dbConn, form, obj.screenshotId);
        }
        else
        {
            resp = await newFile(dbConn, form);
        }
        
        idResp = resp as IdResp;
        
        if (idResp == null)
            return resp;
        
        obj.screenshotId =  idResp.id;
        
        await dbConn.update
        (
            Col.objetoUnity,
            where.id (StringToId (obj.id)), 
            modify.set ('screenshotId', StringToId (idResp.id))
        );
        
        return idResp;
    }
    catch (e, stacktrace)
    {
        return new IdResp()
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route ('/private/objetounity/:id/screenshot', methods: const [app.POST, app.PUT], allowMultipartRequest: true)
@Encode ()
@Secure (ADMIN)
Future<IdResp> newOrUpdateObjetoUnityScreenshot (@app.Attr() MongoDb dbConn, @app.Body(app.FORM) Map form, String id) async
{
    try
    {
        ObjetoUnitySendResp objResp = await getObjetoUnity(dbConn, id);
                
        if (! objResp.success)
            return objResp;
        
        //Updates screenshotId, return IdResp
        return newOrUpdateScreenshot (dbConn, form, objResp.obj);
    }
    catch (e, stacktrace)
    {
        return new IdResp ()
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route ('/private/objetounity/:id/publish', methods: const [app.GET])
@Encode ()
@Secure (ADMIN)
Future publishObjetoUnity (@app.Attr() MongoDb dbConn, String id) async
{
    ObjetoUnitySendResp objResp;
    
    Resp resp = await getObjetoUnity(dbConn, id);
    
    if (! resp.success)
        return resp;
    
    objResp = resp as ObjetoUnitySendResp;
    
    if (! objResp.obj.updatedAll)
        return new Resp ()
            ..error = "No se han actualizado todos los modelos del Objetos Unity";
    
    ObjetoUnitySend obj;
    
    await dbConn.update
    (
        Col.objetoUnity,
        where.id(StringToId(id)),
        modify
            .set('updatePending', false)
            .set('updatedIOS', false)
            .set('updatedAndroid', false)
            .set('updatedMAC', false)
            .set('updatedWindows', false)
            .inc('version', 1)
    );
    
    return new Resp ();
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
            ..objs = objs;
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route ('/private/objetounity/pending', methods: const [app.GET], allowMultipartRequest: true)
@Encode ()
@Secure (ADMIN)
Future getObjetoUnityPending (@app.Attr() MongoDb dbConn) async
{
    try
    {
        List<ObjetoUnitySend> objs = await dbConn.find
        (
            Col.objetoUnity,
            ObjetoUnitySend,
            where
                .eq ('updatePending', true)
        );
        
        return new ObjetoUnitySendListResp()
            ..objs = objs;
    }
    catch (e, stacktrace)
    {
        return new ObjetoUnitySendListResp()
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route('/private/objetounitysend/:id/guardarObjUnitySend', methods: const [app.PUT])
@Encode()
@Secure(ADMIN)
putObjetoUnitySend (@app.Attr() MongoDb dbConn, @Decode() ObjetoUnitySend obj) async
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
        
        return new Resp();
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..error = e.toString() + stacktrace.toString();
    }
}