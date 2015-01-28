part of arista_server;



@app.Route("/private/get/evento/:id/vistas")
@Encode()
Future<VistasResp> getVistas(@app.Attr() MongoDb dbConn, String id)
{
    return getEvento(dbConn, id).then((Evento e)
    {
        if (e == null)
        {
            return new VistasResp()
                ..success = false
                ..error = "Evento no encontrado";
        }
        
        var vistasID = e.viewIds.map(StringToId).toList();
        
        return dbConn.find(Col.vista, Vista, where.oneFrom('_id', vistasID))
        .then((List<Vista> vistas)
        {
            return new VistasResp()
                ..success = true
                ..vistas = vistas;
        });
    });
}

@app.Route("/private/vista",methods: const[app.POST])
@Encode()
Future<VistasResp> newVista(@app.Attr() MongoDb dbConn)
{
        
    var vista = new Vista();
    
    var vistaID = new ObjectId();
    
    vista.id = vistaID.toHexString();

    return dbConn.insert (Col.vista, vista).then((_) => 
        new IdResp()
            ..success = true
            ..id = vista.id
    );

}

@app.Route("/private/vista", methods: const[app.PUT])
@Encode()
Future<IdResp> saveVista(@app.Attr() MongoDb dbConn, @Decode() Vista vista)
{
    var id = StringToId(vista.id);
            
    return dbConn.update(Col.vista, where.id(id), vista)
    .then((_) => new IdResp()
        ..success = true
        ..id = vista.id
    ); 
}

@app.Route("/private/vista/:vistaID", methods: const [app.GET])
@Encode()
Future<IdResp> getVista(@app.Attr() MongoDb dbConn, String vistaID)
{
    var id = StringToId(vistaID);
            
    return dbConn.findOne(Col.vista, Vista, where.id(id))
    .then((Vista vista)
    {
        if (vista == null)
        {
            return new VistaResp()
                ..success = false
                ..error = "Vista not found";
        }
        else
        {
            return new VistaResp()
                ..success = true
                ..vista = vista;
        }
    }); 
}

@app.Route("/private/vista/:vistaID", methods: const [app.DELETE])
@Encode()
Future<IdResp> deleteVista(@app.Attr() MongoDb dbConn, String vistaID)
{
    var id = StringToId(vistaID);
            
    return dbConn.remove(Col.vista, where.id(id))
    .then((_)
    {
        return new Resp()
                ..success = true;
    }); 
}