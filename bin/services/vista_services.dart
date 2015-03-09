part of aristadart.server;

@app.Group('/vista')
@Catch()
class VistaServices extends MongoDbService<Vista>
{
    VistaServices () : super (Col.vista);
    
    @app.DefaultRoute(methods: const [app.POST])
    @Private()
    @Encode()
    Future<Vista> New (@app.QueryParam("type") int typeNumber, @app.QueryParam("eventoId") String eventoId) async
    {
        
        Vista vista = Vista.Factory (Vista.IndexToType[typeNumber])
            ..id = newId()
            ..nombre = "Mi vista"
            ..owner = (new User()
                ..id = userId);
        
        
        await insert
        (
            vista
        );
        
        if (eventoId != null)
            await new EventoServices().AddVista(eventoId, vista.id);
        
        
        return vista;
        
    }
    
    @app.Route('/:id', methods: const [app.GET])
    @Encode()
    Future<Vista> Get (String id) async
    {
        Vista vista = await collection.findOne
        (
            where.id (StringToId (id))
        )
        .then (MapToVista);
        
        if (vista == null)
            throw new Exception("Vista not found");
        
        
        return vista;
    }
    
    @app.Route('/:id', methods: const [app.PUT])
    @Private()
    @Encode()
    Future<Vista> Update (String id, 
                        @app.Body (app.JSON) Map map) async
    {
        Vista delta = MapToVista(map);
        
        await collection.update
        (
            where.id (StringToId (id)),
            getModifierBuilder(delta)
        );
        
        return Get (id);   
    }
    
    @app.Route('/:id', methods: const [app.DELETE])
    @Private()
    @Encode()
    Future<DbObj> Delete (String id) async
    {
        await remove
        (
            where.id (StringToId (id))
        );
        
        return new DbObj()
            ..id = id;
    }
    
    
    @app.Route('/all', methods: const [app.GET])
    @Private()
    @Encode()
    Future<ListVistaResp> All () async
    {
        List<Vista> vistas = await Find
        (
            where.eq("owner._id", StringToId(userId))
        );
        
        return new ListVistaResp()
            ..vistas = vistas;
    }
    
    @app.Route('/:id/setType', methods: const [app.PUT])
    @Private()
    @Encode()
    Future<Vista> SetType (String id, @app.QueryParam("type") int type) async
    {
        Vista delta = Vista.Factory (Vista.IndexToType[type]);
        
        return Update(id, encode (delta));
    }
    
    static Vista MapToVista (Map map)
    {
        return Vista.MapToVista (db.decode, map);
    }
    
    Future<List<Vista>> Find (query)
    {
        return collection.find(query).stream.map (MapToVista).toList();
    }
    
}


Future<VistaExportable> buildVista (MongoDb dbConn, VistaExportable vista) async
{
    print("buildVista");
    switch (vista.type__)
    {
        case 'ConstruccionRAJS, Assembly-CSharp':
            if (notNullOrEmpty(vista.objetoUnityId))
            {
                vista.objetoUnity = await dbConn.findOne
                (
                    Col.objetoUnity,
                    ObjetoUnitySend,
                    where.id (StringToId (vista.objetoUnityId))
                );                
                
            }
            
            if (notNullOrEmpty(vista.localTargetId))
            {
                vista.localTarget = await dbConn.findOne
                (
                    Col.localTarget,
                    LocalImageTargetSend,
                    where.id(StringToId (vista.localTargetId))                    
                );
            }
            
            break;

        default:
            break;
    }
    
    return vista;
}

Resp validVista (VistaExportable vista)
{
    if (vista.type__ == null || vista.type__ == "")
        return new Resp()
            ..error = "type__ undefined.";
    
    switch (vista.type__)
    {
        case 'ConstruccionRAJS, Assembly-CSharp':
            
            if (vista.objetoUnity == null)
                return new Resp()
                    ..error = "modeloId undefined.";
            if (vista.objetoUnity.active == null || vista.objetoUnity.active == false)
                return new Resp()
                    ..error = "El objetoUnity no esta activo.";
            if (vista.localTarget == null)
                return new Resp()
                    ..error = "localTarget undefined.";            
            if (vista.localTarget.active == null || vista.localTarget.active == false)
                 return new Resp()
                    ..error = "El localTarget no esta activo.";            
            
            break;
    }
    
    return new Resp();
}