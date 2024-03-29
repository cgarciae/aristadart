part of aristadart.server;

@app.Group ('/evento')
class EventoServices
{
    @app.DefaultRoute (methods: const[app.POST])
    @Encode()
    Future<EventoDb> New ()
    {
        EventoDb evento = new EventoDb()
            ..id = newId()
            ..active = false;
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
