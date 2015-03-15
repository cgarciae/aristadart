part of aristadart.server;

@app.Group('/vista')
@Catch()
class VistaServices extends AristaService<Vista>
{
    VistaServices () : super (Col.vista);
    
    @app.DefaultRoute(methods: const [app.POST])
    @Private()
    @Encode()
    Future<Vista> New (@app.QueryParam("type") int typeNumber, @app.QueryParam("eventoId") String eventoId) async
    {
        
        Vista vista = new Vista (Vista.IndexToType[typeNumber])
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
        var vista = await collection.findOne
        (
            where.id (StringToId (id))
        )
        .then (MongoMapToVista);
        
        if (vista == null)
            throw new app.ErrorResponse (400, "Vista not found");
        
        return vista;
    }
    
    @app.Route('/:id', methods: const [app.PUT])
    @Private()
    @Encode()
    Future Update (String id, 
                    @app.Body (app.JSON) Map map) async
    {
        var delta = Vista.MapToVista (decode, map);
        
        await UpdateGeneric (id, delta);
        
        return Get (id);
    }
    
    @app.Route('/:id', methods: const [app.DELETE])
    @Private()
    @Encode()
    Future<DbObj> Delete (String id) async
    {
        return DeleteGeneric(id);
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
    
    @app.Route('/:id/export', methods: const [app.GET])
    @Private()
    @Encode()
    Future<Vista> Export (String id, {@app.QueryParam() bool owner,
                          @app.QueryParam() bool objetoUnity,
                          @app.QueryParam() bool localTarget}) async
    {
        Vista vista = await Get (id);
        
        if (owner != null && owner && vista.owner != null)
                    vista.owner = await new UserServives ().GetGeneric(vista.owner.id);
                
        if (vista is ConstruccionRA)
        {
            if (objetoUnity != null && objetoUnity && vista.objetoUnity != null)
                vista.objetoUnity = await new ObjetoUnityServices().Get(vista.objetoUnity.id);
            
            if (localTarget != null && localTarget && vista.localTarget != null) 
                vista.localTarget = await new LocalImageTargetServices().Get(vista.localTarget.id);
            
        }       
        else
        {
            
        }
        
        return vista;
    }
    
    @app.Route('/:id/isValid', methods: const [app.GET])
    @Private()
    @Encode()
    Future<String> IsValid (String id) async
    {
        Vista vista = await Export(id, objetoUnity: true, localTarget: true);
        return vista.valid;
    }
    
    
    static Vista MongoMapToVista (Map map)
    {
        return Vista.MapToVista (db.decode, map);
    }
    
    Future<List<Vista>> Find (query)
    {
        return collection.find(query).stream.map (MongoMapToVista).toList();
    }
    
    Future<Vista> buildVista (Vista vista, {bool owner, bool objetoUnity,
                              bool localTarget}) async
    {
        if (vista == null)
            throw new ArgumentError.notNull("vista");
        
        if (owner && vista.owner != null)
            vista.owner = await new UserServives ().GetGeneric(vista.owner.id);
        
        if (vista is ConstruccionRA)
        {
            if (objetoUnity != null && objetoUnity && vista.objetoUnity != null)
                vista.objetoUnity = await new ObjetoUnityServices().Get(vista.objetoUnity.id);
            
            if (localTarget != null && localTarget && vista.localTarget != null) 
                vista.localTarget = await new LocalImageTargetServices().Get(vista.localTarget.id);
            
        }       
        else
        {
            
        }
        
        return vista;
    }
    
}


