part of arista_server;

@app.Route("/private/pull/:collection/:obj_id/:fieldName/:reference_id")
@Encode()
Future<Resp> pullIdFromList(@app.Attr() MongoDb dbConn, String collection, String obj_id, String fieldName, String reference_id)
{
    var objID = StringToId(obj_id);
    var referenceID = StringToId(reference_id);
    
    return dbConn.update(collection, where.id(objID), modify.pull(fieldName, referenceID))
    .then((_)
    {
        return new Resp()
            ..success = true;
    });
}

@app.Route("/private/push/:collection/:obj_id/:fieldName/:reference_id")
@Encode()
Future<Resp> pushIdToList(@app.Attr() MongoDb dbConn, String collection, String obj_id, String fieldName, String reference_id)
{
    var objID = StringToId(obj_id);
    var referenceID = StringToId(reference_id);
    
    return dbConn.update(collection, where.id(objID), modify.push(fieldName, referenceID))
    .then((_)
    {
        return new Resp()
            ..success = true;
    });
}

@app.Route("/upload", methods: const [app.POST], allowMultipartRequest: true)
@Encode()
upload(@app.Body(app.FORM) Map file)
{
    
    print (file);
    
    HttpBodyFileUpload f = file['file'];
    
    print (f);
    
    print (f.runtimeType);
    
    print(file.runtimeType);
    
    return new Resp()
        ..success = (file != null);
}