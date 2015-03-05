part of aristadart.server;

@app.Group ('/evento')
class EventoServices extends MongoDbService<Evento>
{
    EventoServices () : super (Col.evento);
    
    @app.DefaultRoute (methods: const[app.POST])
    @Private()
    @Encode()
    Future<Evento> New () async
    {
        try
        {
            Evento evento = new Evento()
                ..id = newId()
                ..active = true
                ..vistas = []
                ..owner = (new User()
                    ..id = userId);
            
            
            await db.insert 
            (   
                Col.evento, 
                evento
            );
            
            return evento;
        }
        catch (e, s)
        {
            return new Evento()
                ..error = "$e $s";
        } 
    }
    
    @app.Route ('/:id', methods: const[app.PUT])
    @Private()
    @Encode()
    Future<Evento> Update (String id, @Decode() Evento delta) async
    {
        try
        {
            await db.update 
            (   
                Col.evento,
                where.id (StringToId (id)),
                getModifierBuilder (delta)
            );
            
            return Get (id);
        }
        catch (e, s)
        {
            return new Evento()
                ..error = "$e $s";
        }
    }
    
    @app.Route ('/:id', methods: const[app.GET])
    @Encode()
    Future<Evento> Get (String id) async
    {
        try
        {
            Evento evento = await db.findOne
            (
                Col.evento,
                Evento,
                where.id(StringToId(id))
            );
            
            if (evento == null)
                return new Evento()
                    ..error = "Evento no encontrado";
            
            return evento;
        }
        catch (e, s)
        {
            return new Evento()
                ..error = "$e $s";
        }
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
    Future<Vista> AddEvento (String id, String vistaId) async
    {
        try
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
        catch (e, s)
        {
            return new Vista ()
                ..error = "$e $s";
        }
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
            
            List<VistaTotal> vistasTotal = await db.find
            (
                Col.vista,
                VistaTotal,
                where.oneFrom("_id", vistasId)
            ).t;
            
            print (encodeJson(vistasTotal));
            
            List<Vista> vistas = vistasTotal.map((VistaTotal v){
                
                Vista vista = v.vista;
                
                print (vista.runtimeType);
                print (encodeJson(vista.eventos));
                
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
            where.eq("owner._id", userId) 
        );
        
        return new ListEventoResp()
            ..eventos = eventos;
    }
}


/////////
//LEGACY
/////////

@app.Route("/private/evento", methods: const[app.POST])
@Encode()
Future<IdResp> newEvent(@app.Attr() MongoDb dbConn) async
{
    EventoCompleto evento = new EventoCompleto()
        ..id = new ObjectId().toHexString()
        ..active = false;

    await dbConn.insert (Col.evento, evento);

    var userId = session['id'];
    
    if (userId == null)
        return new IdResp()
            ..error = 'User not found';

    await dbConn.update
    (
        Col.user,
        where.id (userId), 
        modify.push ('eventos', StringToId (evento.id))
    );

    return new IdResp()
      ..id = evento.id;
}

@app.Route("/private/evento", methods: const [app.PUT])
@Encode()
Future<IdResp> saveEvent(@app.Attr() MongoDb dbConn, @Decode() Evento evento) async
{
    await dbConn.update(Col.evento, where.id(StringToId(evento.id)), evento);

    return new IdResp()
        ..id = evento.id;
}

@app.Route("/private/evento/:id", methods: const [app.GET])
@Encode()
Future<Evento> getEvento(@app.Attr() MongoDb dbConn, String id) async
{
    //TODO: Retornar EventoResp
    return dbConn.findOne
    (
        Col.evento, 
        Evento, 
        where.id(StringToId(id))
    );
}

@app.Route("/private/evento/:id", methods: const [app.DELETE])
@Encode()
deleteEvento(@app.Attr() MongoDb dbConn, String id) async
{
    var eventoId = StringToId(id);
    ObjectId userID = session['id'];

    await dbConn.update (Col.user, where.id(userID), modify.pull('eventos', eventoId));
    await dbConn.remove (Col.evento, where.id(eventoId));
    
    return new Resp();
}

@app.Route("/private/activate/:status/evento/:eventoID")
@Encode()
Future<Resp> activateEvento(@app.Attr() MongoDb dbConn, bool status, String eventoID) async
{
    String aristaRecoID;

    EventoCompleto evento = await dbConn.findOne
    (
        Col.evento, 
        EventoCompleto, 
        where.id (StringToId (eventoID))
    );
    
    if (evento == null) 
        return new Resp()
            ..error = "Evento not found";

    aristaRecoID = evento.cloudRecoTargetId;
    
    CloudImageTarget reco = await dbConn.findOne
    (
        Col.recoTarget,
        CloudImageTarget, 
        where.id(StringToId(aristaRecoID))
    );
    
    if (reco == null)
        return new Resp()
            ..error = "Cloud Reco not found";

    await dbConn.update
    (
        Col.evento,
        where.id (StringToId (eventoID)),
        modify.set('active', status)
    );
    
    QueryMap map = await makeVuforiaRequest 
    (
        Method.PUT, 
        "/targets/${reco.targetId}", 
        conv.JSON.encode
        ({
            "active_flag": status
        }), 
        ContType.applicationJson
    )
    .send()
    .then (streamResponseToJSON)
    .then (MapToQueryMap);
        

    if (map.result_code == "Success") 
    {
        return new Resp();
    } 
    else 
    {
        return new Resp()
            ..error = map.result_code;
    }
}

@app.Route('/all/evento')
@Encode()
allEventos(@app.Attr() MongoDb dbConn) 
{
    return dbConn.find(Col.evento, Evento);
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
