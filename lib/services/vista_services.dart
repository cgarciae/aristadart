part of arista_server;



@app.Route("/private/evento/:id/vistas")
@Encode()
Future<VistasResp> getVistas(@app.Attr() MongoDb dbConn, String id) async
{
    Evento evento = await getEvento(dbConn, id);

    if (evento == null)
    {
        return new VistasResp()
            ..success = false
            ..error = "Evento no encontrado";
    }
    
    var vistasID = evento.viewIds.map(StringToId).toList();
    
    List<Vista> vistas = await dbConn.find(Col.vista, Vista, where.oneFrom('_id', vistasID));

    return new VistasResp()
        ..success = true
        ..vistas = vistas;
}

@app.Route("/private/vista",methods: const[app.POST])
@Encode()
Future<VistasResp> newVista(@app.Attr() MongoDb dbConn) async
{
        
    var vista = new Vista()
        ..id = new ObjectId().toHexString();

    await dbConn.insert (Col.vista, vista);
    
    return new IdResp()
        ..success = true
        ..id = vista.id;
}

@app.Route("/private/vista", methods: const[app.PUT])
@Encode()
Future<IdResp> saveVista(@app.Attr() MongoDb dbConn, @Decode() Vista vista) async
{
    await dbConn.update(Col.vista, where.id(StringToId(vista.id)), vista);
    
    return new IdResp()
        ..success = true
        ..id = vista.id; 
}

@app.Route("/private/vista/:vistaID", methods: const [app.GET])
@Encode()
Future<IdResp> getVista(@app.Attr() MongoDb dbConn, String vistaID) async
{
    var id = StringToId(vistaID);
            
    Vista vista = await dbConn.findOne(Col.vista, Vista, where.id(id));

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
}

@app.Route("/private/vista/:vistaID", methods: const [app.DELETE])
@Encode()
Future<IdResp> deleteVista(@app.Attr() MongoDb dbConn, String vistaID) async
{           
    await dbConn.remove(Col.vista, where.id(StringToId(vistaID)));
    
    return new Resp()
        ..success = true;
}

Future<bool> validVista (VistaExportable vista) async
{
    //TODO: HACER
    return true;
}