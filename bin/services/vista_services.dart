part of aristadart.server;

@app.Group('/vista')
class VistaServices extends MongoDbService<VistaTotal>
{
    VistaServices () : super (Col.vista);
    
    @app.DefaultRoute(methods: const [app.POST])
    @Catch()
    @Private()
    @Encode()
    Future<Vista> New (@app.QueryParam("type") int typeNumber, @app.QueryParam("eventoId") String eventoId) async
    {
        
        Vista vista = Vista.Factory (Vista.IndexToType[typeNumber])
            ..id = newId()
            ..owner = (new User()
                ..id = userId);
        
        
        await db.insert
        (
            Col.vista,
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
        try
        {
            VistaTotal vistaTotal = await db.findOne
            (
                Col.vista,
                VistaTotal,
                where.id (StringToId (id))
            );
            
            if (vistaTotal == null)
                return new Vista()
                    ..error = "Vista not found";
            
            
            return vistaTotal.vista;
        }
        catch (e, s)
        {
            return new Vista ()
                ..error = "$e $s";
        }
    }
    
    @app.Route('/:id', methods: const [app.PUT])
    @Private()
    @Encode()
    Future<Vista> Update (String id, @Decode() VistaTotal vista) async
    {
        try
        {
            
            await db.update
            (
                Col.vista,
                where.id (StringToId (id)),
                getModifierBuilder(vista)
            );
            
            return Get (id);
        }
        catch (e, s)
        {
            return new Vista ()
                ..error = "$e $s";
        }
    }
    
    @app.Route('/:id', methods: const [app.DELETE])
    @Private()
    @Encode()
    Future<DbObj> Delete (String id) async
    {
        try
        {
            
            await remove
            (
                where.id (StringToId (id))
            );
            
            return new DbObj()
                ..id = id;
        }
        catch (e, s)
        {
            return new DbObj ()
                ..error = "$e $s";
        }
    }
    
    
    @app.Route('/all', methods: const [app.GET])
    @Private()
    @Encode()
    Future<ListVistaResp> All () async
    {
        try
        {
            List<VistaTotal> vistasTotal = await find
            (
                where.eq("owner._id", StringToId(userId))
            );
            
            List<Vista> vistas = vistasTotal.map((VistaTotal v) => v.vista).toList();
            
            return new ListVistaResp()
                ..vistas = vistas;
        }
        catch (e, s)
        {
            return new ListVistaResp()
                ..error = "$e $s";
        }
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