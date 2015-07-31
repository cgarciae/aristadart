part of aristadart.server;

@app.Group ('/evento')
@Catch()
class EventoServices extends AristaService<Evento>
{
    VistaServices vistaServices;
    EventoServices (this.vistaServices, MongoDb mongoDb) : super (Col.evento, mongoDb);
    
    @app.DefaultRoute (methods: const[app.POST])
    @Private()
    @Encode()
    Future<Evento> New (@Authorization String userId) async
    {
        Evento evento = new Evento()
            ..id = newId()
            ..nombre = "Mi Evento"
            ..descripcion = "Descripcion"
            ..active = true
            ..vistas = []
            ..owner = (new User()
                ..id = userId);
        
        return NewGeneric (evento);
    }
    
    @app.Route ('/:id', methods: const[app.PUT])
    @Private()
    @Encode()
    Future<Evento> Update (String id, @Decode() Evento delta) async
    {
        await UpdateGeneric(id, delta);   
        return Get (id);
    }
    
    @app.Route ('/:id', methods: const[app.GET])
    @Encode()
    Future<Evento> Get (String id) async
    {
        return GetGeneric(id);
    }
    
    @app.Route ('/:id', methods: const[app.DELETE])
    @Private()
    @Encode()
    Future<DbObj> Delete (String id) async
    {
        return DeleteGeneric(id);
    }
    
    @app.Route('/:id/addVista/:vistaId', methods: const [app.POST, app.PUT])
    @Private()
    @Encode()
    Future<Evento> AddVista (String id, String vistaId) async
    {
        
        var vista = new EmptyVista()
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
        
        var vista = new EmptyVista()
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
    Future<List<Vista>> Vistas (String id) async
    {
        Evento evento = await Get (id);
        
        if (evento.vistas == null || evento.vistas.isEmpty)
            return [];
        
        var vistasId = evento.vistas
                .map((v) => v.id)
                .map(StringToId)
                .toList();
        
        List<Vista> vistas = await vistaServices.Find
        (
            where.oneFrom("_id", vistasId)
        );
        
        return vistas; 
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
    
    @app.Route ('/:id/export', methods: const[app.GET])
    @Encode()
    Future<Evento> Export (String id, {@app.QueryParam() bool checkValid : true}) async
    {
        Evento evento = await Get (id);
        
        evento.vistas = await Vistas (id);
        
        List<Vista> vistas = [];
        
        for (Vista _vista in evento.vistas)
        {
            Vista vista = await vistaServices.Export
            (
                    _vista.id,
                    objetoUnity: true,
                    localTarget: true
            );
            
            if (checkValid == null || !checkValid || vista.valid)
                vistas.add (vista);
        }
        
        evento.vistas = vistas;
        
        if (checkValid != null && checkValid && !evento.valid)
            throw new app.ErrorResponse (400, "Evento invalido");
        
        return evento;
    }

    Stream<Evento> ExportMany_ (Iterable<String> ids) async * {

        for (var id in ids) {
            try {
                Evento evento = await Export(id);
                yield evento;
            }
            catch(e){}
        }
    }

    @app.Route ('/get-demos', methods: const[app.GET])
    @Encode()
    Future<List<Evento>> GetDemos () async {
        List<Evento> demos = await find(where.eq("demo", true));
        return ExportMany_(demos.map((e) => e.id)).toList();
    }

}

