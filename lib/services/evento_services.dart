part of arista_server;



@app.Route("/private/evento",methods: const[app.POST])
@Encode()
newEvent(@app.Attr() MongoDb dbConn) {
    var evento = new Evento();

    ObjectId eventoId = new ObjectId();

    evento.id = eventoId.toHexString();

    return dbConn.insert(Col.evento, evento).then((_) {

        var userId = session['id'];

        return dbConn.collection(Col.user).update(where.id(userId), modify.push('eventos', eventoId));
    }).then((_) {
        return new IdResp()
          ..success = true
          ..id = evento.id;
    });
}

@app.Route("/private/evento", methods: const [app.PUT])
@Encode()
Future<IdResp> saveEvent(@app.Attr() MongoDb dbConn, @Decode() Evento evento) {
    var id = StringToId(evento.id);

    return dbConn.update(Col.evento, where.id(id), evento).then((_) => new IdResp()
            ..success = true
            ..id = evento.id);
}

@app.Route("/private/evento/:id", methods: const [app.GET])
@Encode()
Future<Evento> getEvento(@app.Attr() MongoDb dbConn, String id) {
    var eventoId = StringToId(id);

    return dbConn.findOne(Col.evento, Evento, where.id(eventoId));
}

@app.Route("/private/evento/:id", methods: const [app.DELETE])
@Encode()
deleteEvento(@app.Attr() MongoDb dbConn, String id) {
    var eventoId = StringToId(id);

    ObjectId userID = session['id'];

    return dbConn.collection(Col.user).update(where.id(userID), modify.pull('eventos', eventoId)).then((_) {
        return dbConn.remove(Col.evento, where.id(eventoId));
    }).then((_) {
        return new Resp()..success = true;
    });
}

@app.Route("/private/activate/:status/evento/:eventoID")
@Encode()
Future<Resp> activateEvento(@app.Attr() MongoDb dbConn, bool status, String eventoID) {
    String aristaRecoID;

    return dbConn.findOne(Col.evento, EventoActive, where.id(StringToId(eventoID))).then((EventoActive evento) {
        if (evento == null) return new Resp()
                ..success = false
                ..error = "Evento not found";

        evento.active = status;
        aristaRecoID = evento.cloudRecoTargetId;

        return dbConn.update(Col.evento, where.id(StringToId(eventoID)), evento);
    }).then((resp) {
        if (resp is Resp) return resp;

        return dbConn.findOne(Col.recoTarget, AristaCloudRecoTargetComplete, where.id(StringToId(aristaRecoID)));
    }).then((resp) {
        if (resp is Resp) return resp;

        AristaCloudRecoTargetComplete reco = resp as AristaCloudRecoTargetComplete;

        String body = conv.JSON.encode({
            "active_flag": status
        });

        return makeVuforiaRequest(Method.PUT, "/targets/${reco.targetId}", body, ContType.applicationJson).send()
        
        .then (streamResponseToJSON).then (MapToQueryMap);
    })
    .then((resp) {
        if (resp is Resp) return resp;

        QueryMap map = resp as QueryMap;

        if (map.result_code == "Success") {
            return new Resp()..success = true;
        } else {
            return new Resp()
                    ..success = false
                    ..error = map.result_code;
        }
    });
}

@app.Route('/all/evento')
@Encode()
allEventos(@app.Attr() MongoDb dbConn) {
    return dbConn.find(Col.evento, Evento);
}

@app.Route('/export/evento/:id')
@Encode()
exportEvento(@app.Attr() MongoDb dbConn, String id) {
    var eventoId = StringToId(id);

    return dbConn.findOne(Col.evento, EventoExportable, where.id(eventoId)).then((EventoExportable evento) {
        print('1 Numero vistas ${evento.viewIds.length}');
        evento.viewIds.forEach(print);

        return BuildEvento(dbConn, evento);
    });
//    .then((EventoExportable evento)
//    {
//
//    });
}

Future<EventoExportable> BuildEvento(MongoDb dbConn, EventoExportable evento) {
    var objIDs = evento.viewIds.map(StringToId).toList();

    print('2 Numero vistas ${objIDs.length}');

    return dbConn.find(Col.vista, VistaExportable, where.oneFrom('_id', objIDs)).then((List<VistaExportable> vistas) {
        return evento..vistas = vistas;
    });
}
