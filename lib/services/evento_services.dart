part of arista_server;



@app.Route("/private/evento",methods: const[app.POST])
@Encode()
newEvent(@app.Attr() MongoDb dbConn) async
{
    var evento = new Evento()
        ..id = new ObjectId().toHexString();

    await dbConn.insert (Col.evento, evento);

    var userId = session['id'];

    await dbConn.collection(Col.user).update(where.id(userId), modify.push('eventos', evento.id));

    return new IdResp()
      ..success = true
      ..id = evento.id;
}

@app.Route("/private/evento", methods: const [app.PUT])
@Encode()
Future<IdResp> saveEvent(@app.Attr() MongoDb dbConn, @Decode() Evento evento) async
{
    await dbConn.update(Col.evento, where.id(StringToId(evento.id)), evento);

    return new IdResp()
        ..success = true
        ..id = evento.id;
}

@app.Route("/private/evento/:id", methods: const [app.GET])
@Encode()
Future<Evento> getEvento(@app.Attr() MongoDb dbConn, String id) async
{
    return dbConn.findOne(Col.evento, Evento, where.id(StringToId(id)));
}

@app.Route("/private/evento/:id", methods: const [app.DELETE])
@Encode()
deleteEvento(@app.Attr() MongoDb dbConn, String id) async
{
    var eventoId = StringToId(id);
    ObjectId userID = session['id'];

    await dbConn.update (Col.user, where.id(userID), modify.pull('eventos', eventoId));
    await dbConn.remove (Col.evento, where.id(eventoId));
    
    return new Resp()..success = true;
}

@app.Route("/private/activate/:status/evento/:eventoID")
@Encode()
Future<Resp> activateEvento(@app.Attr() MongoDb dbConn, bool status, String eventoID) async
{
    String aristaRecoID;

    EventoActive evento = await dbConn.findOne
    (
        Col.evento, 
        EventoActive, 
        where.id(StringToId(eventoID))
    );
    
    if (evento == null) 
        return new Resp()
            ..success = false
            ..error = "Evento not found";

    evento.active = status;
    aristaRecoID = evento.cloudRecoTargetId;

    await dbConn.update(Col.evento, where.id(StringToId(eventoID)), evento);
    
    AristaCloudRecoTarget reco = await dbConn.findOne(Col.recoTarget, AristaCloudRecoTarget, where.id(StringToId(aristaRecoID)));
    
    if (reco == null)
        return new Resp()
            ..success = false
            ..error = "Cloud Reco not found";

    String body = conv.JSON.encode
    ({
        "active_flag": status
    });

    QueryMap map = await makeVuforiaRequest (Method.PUT, "/targets/${reco.targetId}", body, ContType.applicationJson)
        .send()
        .then (streamResponseToJSON)
        .then (MapToQueryMap);
        

    if (map.result_code == "Success") 
    {
        return new Resp()..success = true;
    } 
    else 
    {
        return new Resp()
            ..success = false
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
    
    evento.viewIds.forEach(print);

    return BuildEvento(dbConn, evento);
}

Future<EventoExportable> BuildEvento(MongoDb dbConn, EventoExportable evento) async
{
    var objIDs = evento.viewIds.map (StringToId).toList();

    List<VistaExportable> vistas = await dbConn.find
    (
        Col.vista, 
        VistaExportable, 
        where.oneFrom('_id', objIDs)
    );

    return evento..vistas = vistas;
}
