part of aristadart.server;

@app.Group ('/evento')
@Catch()
class EventoServices extends MongoDbService<Evento>
{
    EventoServices () : super (Col.evento);
    
    @app.DefaultRoute (methods: const[app.POST])
    @Private()
    @Encode()
    Future<Evento> New () async
    {
        Evento evento = new Evento()
            ..id = newId()
            ..nombre = "Mi Evento"
            ..descripcion = "Descripcion"
            ..active = true
            ..vistas = []
            ..owner = (new User()
                ..id = userId);
        
        await insert
        (
            evento
        );
        
        return evento;
    }
    
    @app.Route ('/:id', methods: const[app.PUT])
    @Private()
    @Encode()
    Future<Evento> Update (String id, @Decode() Evento delta) async
    {
        await db.update 
        (   
            Col.evento,
            where.id (StringToId (id)),
            getModifierBuilder (delta)
        );
            
        return Get (id);

    }
    
    @app.Route ('/:id', methods: const[app.GET])
    @Encode()
    Future<Evento> Get (String id) async
    {
        Evento evento = await db.findOne
        (
            Col.evento,
            Evento,
            where.id(StringToId(id))
        );
            
        if (evento == null)
            throw new Exception ("Evento no encontrado");
          
        return evento;
    }
    
    @app.Route ('/:id', methods: const[app.DELETE])
    @Private()
    @Encode()
    Future<DbObj> Delete (String id) async
    {
        try
        {
            await db.remove
            (
                Col.evento,
                where.id(StringToId(id))
            );
            
            return new DbObj()
                ..id = id;
        }
        catch (e, s)
        {
            return new DbObj()
                ..error = "$e $s";
        }
    }
    
    @app.Route('/:id/addVista/:vistaId', methods: const [app.POST, app.PUT])
    @Private()
    @Encode()
    Future<Evento> AddVista (String id, String vistaId) async
    {
        
        var vista = new Vista()
            ..id = vistaId;
        
        await db.update
        (
            collectionName,
            where.id(StringToId(id)),
            modify.addToSet
            (
                "vistas", 
                cleanMap(db.encode(vista))
            )
        );
        
        return Get (id);
        
    }
    
    @app.Route('/:id/removeVista/:vistaId', methods: const [app.POST, app.PUT])
    @Private()
    @Encode()
    Future<Evento> RemoveVista (String id, String vistaId) async
    {
        
        var vista = new Vista()
            ..id = vistaId;
        
        await db.update
        (
            collectionName,
            where.id(StringToId(id)),
            {
                r'$pull' : 
                {
                    'vistas' :
                    {
                        '_id' : StringToId (vistaId)
                    }
                }
            }
        );
        
        return Get (id);
        
    }
    
    @app.Route ('/:id/vistas', methods: const[app.GET])
    @Private()
    @Encode()
    Future<ListVistaResp> Vistas (String id) async
    {
        try
        {
            Evento evento = await Get (id);
            
            if (evento.failed)
                return new ListVistaResp ()
                    ..error = evento.error;
            
            if (evento.vistas == null || evento.vistas.isEmpty)
                return new ListVistaResp ()
                    ..vistas = [];
            
            var vistasId = evento.vistas
                    .map(F.getField(#id))
                    .map(StringToId)
                    .toList();
            
            List<VistaTotal> vistasTotal = await new VistaServices().find
            (
                where.oneFrom("_id", vistasId)
            );
            
            List<Vista> vistas = vistasTotal.map((VistaTotal v){
                
                Vista vista = v.vista;
                
                return vista;
                
            }).toList();
            
            return new ListVistaResp()
                ..vistas = vistas;
        }
        catch (e, s)
        {
            return new ListVistaResp()
                ..error = "$e $s";
        }
    }
    
    @app.Route ('/all', methods: const[app.GET])
    @Private()
    @Encode()
    Future<ListEventoResp> All () async
    {
        List<Evento> eventos = await find
        (
            where.eq("owner._id", StringToId (userId)) 
        );
        
        return new ListEventoResp()
            ..eventos = eventos;
    }
}

@app.Route('/export/evento/:id')
@Encode()
exportEvento(@app.Attr() MongoDb dbConn, String id) async
{
    EventoExportable evento = await dbConn.findOne
    (
        Col.evento,
        EventoExportable, 
        where.id (StringToId (id))
    );
    
    
    if (evento == null)
        return new EventoExportableResp()
            ..error = "Evento no found"
            ..errCode = ErrCode.NOTFOUND;

    print ("EE 1");
    await BuildEvento(dbConn, evento);
    
    print ("EE 2");
    Resp resp = evento.valid();
    
    if (resp.success)
    {
        return new EventoExportableResp()
            ..evento = evento;
    }
    else
    {
        return new EventoExportableResp()
            ..error = "Evento Invalido: ${resp.error}";
    }
}

Future<EventoExportable> BuildEvento(MongoDb dbConn, EventoExportable evento) async
{
    print ("BE 1");
    var objIDs = evento.viewIds.map (StringToId).toList();

    evento.vistas = await dbConn.find
    (
        Col.vista, 
        VistaExportable, 
        where
            .oneFrom('_id', objIDs)
    );

    var futures = evento.vistas.map((VistaExportable vista) 
            => buildVista(dbConn, vista)).toList();
    
    await Future.wait (futures);
    
    return evento;
}
