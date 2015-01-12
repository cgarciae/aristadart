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
        .update(where.id(userId), {r'$push': {'eventos' : eventoId}});
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
        
    return dbConn.update(Col.evento, where.id(id), evento)
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
allEventos (@app.Attr() MongoDb dbConn)
{
    dbConn.find(Col.evento, Evento)
    .then((List<Evento> eventos)
    {
       eventos.map(F.getField(#id)).forEach(print); 
       
       var s = r'''{
            "_id": "ObjectId(\"54ada37d79a0869c1e635daf\")",
            "imagenPreview": {
                "urlTextura": "",
                "texto": "",
                "type__": "TextureGUIJS, Assembly-CSharp"
            },
            "nombre": "test",
            "descripcion": "",
            "type__": "EventoJS, Assembly-CSharp",
            "url": "http://localhost:8080/id/54ada37d79a0869c1e635daf"
        }''';
       
       print ("Evento ID ${decodeJson(s, Evento).id}");
       
    });
}