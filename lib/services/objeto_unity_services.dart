part of arista_server;


@app.Route('/private/objetounity', methods: const [app.POST])
@Encode()
newFileRevision (@app.Attr() MongoDb dbConn) async
{
    var obj = new ObjetoUnitySend()
        ..id = new ObjectId().toHexString()
        ..name = "Nuevo Nombre"
        ..version = 0
        ..active = false;
    
    await dbConn.insert(Col.objetoUnity, obj);
    
    return new ObjetoUnitySendResp()
        ..success = true
        ..obj = obj;
}
