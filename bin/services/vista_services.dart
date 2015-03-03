part of aristadart.server;

@app.Group('/vista')
class VistaServices
{
    @app.DefaultRoute(methods: const [app.POST])
    @Private()
    @Encode()
    Future<Vista> New (@app.QueryParam("type") String type) async
    {
        try
        {
            Vista vista = new Vista ()
                ..id = newId();
            
            await db.insert
            (
                Col.vista,
                vista
            );
            
            return vista;
        }
        catch (e, s)
        {
            return new Vista ()
                ..error = "$e $s";
        }
    }
    
    @app.Route('/:id', methods: const [app.GET])
    @Private()
    @Encode()
    Future<Vista> Get (String id) async
    {
        try
        {
            VistaTotal vistaTotal = await db.findOne
            (
                Col.vista,
                VistaTotal,
                where.id (StringToId (id))
            );
            
            if (vistaTotal == null)
                return new Vista()
                    ..error = "Vista not found";
            
            return vistaTotal.vista;
        }
        catch (e, s)
        {
            return new Vista ()
                ..error = "$e $s";
        }
    }
    
    @app.Route('/:id', methods: const [app.PUT])
    @Private()
    @Encode()
    Future<Vista> Update (String id, @Decode() VistaTotal vistaTotal) async
    {
        try
        {
            Vista vista = vistaTotal.vista;
            
            await db.update
            (
                Col.vista,
                where.id (StringToId (id)),
                getModifierBuilder(vista)
            );
            
            if (vistaTotal == null)
                return new Vista()
                    ..error = "Vista not found";
            
            return vistaTotal.vista;
        }
        catch (e, s)
        {
            return new Vista ()
                ..error = "$e $s";
        }
    }
}


@app.Route("/private/evento/:id/vistas")
@Encode()
Future<VistasResp> getVistas(@app.Attr() MongoDb dbConn, String id) async
{
    Evento evento = await getEvento(dbConn, id);

    if (evento == null)
    {
        return new VistasResp()
            ..error = "Evento no encontrado";
    }
    
    var vistasID = evento.viewIds.map(StringToId).toList();
    
    List<Vista> vistas = await dbConn.find(Col.vista, Vista, where.oneFrom('_id', vistasID));

    return new VistasResp()
        ..vistas = vistas;
}

@deprecated
@app.Route("/private/vista",methods: const[app.POST])
@Encode()
Future<IdResp> newVista(@app.Attr() MongoDb dbConn) async
{
        
    var vista = new Vista()
        ..id = new ObjectId().toHexString();

    await dbConn.insert (Col.vista, vista);
    
    return new IdResp()
        ..id = vista.id;
}

@app.Route("/vista",methods: const[app.POST])
@Private()
@Encode()
Future<IdResp> newVista2() async
{
        
    var vista = new Vista()
        ..id = new ObjectId().toHexString();

    await db.insert (Col.vista, vista);
    
    return new IdResp()
        ..id = vista.id;
}

@app.Route("/private/vista", methods: const[app.PUT])
@Encode()
Future<Resp> saveVista(@Decode() Vista vista) async
{
    print (app.request.body);
    
    //print (vista.muebles[0].imageId);
    
    await db.update
    (   
        Col.vista, 
        where.id(StringToId(vista.id)), 
        vista
    );
    
    return new Resp();
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
            ..error = "Vista not found";
    }
    else
    {
        return new VistaResp()
            ..vista = vista;
    }
}

@app.Route("/private/vista/:vistaID", methods: const [app.DELETE])
@Encode()
Future<Resp> deleteVista(@app.Attr() MongoDb dbConn, String vistaID) async
{           
    await dbConn.remove(Col.vista, where.id(StringToId(vistaID)));
    
    return new Resp();
}

@app.Route("/export/vista/:vistaID", methods: const [app.GET])
@Encode()
Future<IdResp> exportarVista(@app.Attr() MongoDb dbConn, String vistaID) async
{ 
    
}

Future<VistaExportable> buildVista (MongoDb dbConn, VistaExportable vista) async
{
    print("buildVista");
    switch (vista.type__)
    {
        case 'ConstruccionRAJS, Assembly-CSharp':
            if (notNullOrEmpty(vista.objetoUnityId))
            {
                vista.objetoUnity = await dbConn.findOne
                (
                    Col.objetoUnity,
                    ObjetoUnitySend,
                    where.id (StringToId (vista.objetoUnityId))
                );                
                
            }
            
            if (notNullOrEmpty(vista.localTargetId))
            {
                vista.localTarget = await dbConn.findOne
                (
                    Col.localTarget,
                    LocalImageTargetSend,
                    where.id(StringToId (vista.localTargetId))                    
                );
            }
            
            break;

        default:
            break;
    }
    
    return vista;
}

Resp validVista (VistaExportable vista)
{
    if (vista.type__ == null || vista.type__ == "")
        return new Resp()
            ..error = "type__ undefined.";
    
    switch (vista.type__)
    {
        case 'ConstruccionRAJS, Assembly-CSharp':
            
            if (vista.objetoUnity == null)
                return new Resp()
                    ..error = "modeloId undefined.";
            if (vista.objetoUnity.active == null || vista.objetoUnity.active == false)
                return new Resp()
                    ..error = "El objetoUnity no esta activo.";
            if (vista.localTarget == null)
                return new Resp()
                    ..error = "localTarget undefined.";            
            if (vista.localTarget.active == null || vista.localTarget.active == false)
                 return new Resp()
                    ..error = "El localTarget no esta activo.";            
            
            break;
    }
    
    return new Resp();
}