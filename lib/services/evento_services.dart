part of arista_server;



@app.Route("/private/new/evento")
newEvent(@app.Attr() MongoDb dbConn)
{
    var evento = new Evento();
    
    ObjectId eventoId = new ObjectId();
                
    evento.id = eventoId.toHexString();
    
    return dbConn
                
    .insert(Col.evento, evento)
    
    .then((_)
    {
        
        var userId = session['id'];
        
        return dbConn.collection(Col.user)
        
        .update (where.id(userId), modify.push ('eventos', eventoId));
    })
    
    .then((_)
    {
        return 
        {
            'success' : true,
            'id' : evento.id
        };
    });
}

@app.Route("/private/save/evento", methods: const[app.POST])
@Encode()
Future<IdResp> saveEvent(@app.Attr() MongoDb dbConn, @Decode() Evento evento) 
{
    var id = StringToId(evento.id);
        
    return dbConn.update (Col.evento, where.id (id), evento)
            
    .then((_) => new IdResp()
        ..success = true
        ..id = evento.id
    );   
}

@app.Route("/private/get/evento/:id")
@Encode()
Future<Evento> getEvento(@app.Attr() MongoDb dbConn, String id)
{
    var eventoId = StringToId(id);
    
    return dbConn.findOne(Col.evento, Evento, where.id(eventoId));
}

@app.Route("/private/get2/evento/:id")
@Encode()
Future<EventoExportable> getEvento2(@app.Attr() MongoDb dbConn, String id)
{
    var eventoId = StringToId(id);
    
    return dbConn.findOne(Col.evento, EventoExportable, where.id(eventoId));
}



@app.Route("/private/delete/evento/:id")
@Encode()
deleteEvento(@app.Attr() MongoDb dbConn, String id)
{
    var eventoId = StringToId(id);
    
    ObjectId userID = session['id'];
    
    return dbConn.collection (Col.user)
            
    .update (where.id (userID), modify.pull ('eventos', eventoId)).then((_)
    {
        return dbConn.remove(Col.evento, where.id(eventoId));
    })
    .then((_)
    {
        return new Resp()
            ..success = true;
    });
}


@app.Route ('/all/evento')
@Encode()
allEventos (@app.Attr() MongoDb dbConn)
{
    return dbConn.find(Col.evento, Evento);
}

@app.Route ('/export/evento/:id')
@Encode()
exportEvento (@app.Attr() MongoDb dbConn, String id)
{
    var eventoId = StringToId(id);
    
    return dbConn.findOne(Col.evento, EventoExportable, where.id(eventoId)).then((EventoExportable evento)
    {
        print ('1 Numero vistas ${evento.viewIds.length}');
        evento.viewIds.forEach(print);
        
        return BuildEvento(dbConn, evento);
    });
//    .then((EventoExportable evento)
//    {
//        
//    });
}

Future<EventoExportable> BuildEvento (MongoDb dbConn, EventoExportable evento)
{
    var objIDs = evento.viewIds.map(StringToId).toList();
    
    print ('2 Numero vistas ${objIDs.length}');
    
    return dbConn.find (Col.vista, VistaExportable, where.oneFrom('_id', objIDs)).then((List<VistaExportable> vistas)
    {
        return evento..vistas = vistas;
    });
}