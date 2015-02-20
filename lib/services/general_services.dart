part of arista_server;

@app.Route("/private/pull/:collection/:obj_id/:fieldName/:reference_id")
@Encode()
Future<Resp> pullIdFromList(@app.Attr() MongoDb dbConn, String collection, String obj_id, String fieldName, String reference_id) async
{
    var objID = StringToId(obj_id);
    var referenceID = StringToId(reference_id);
    
    await dbConn.update
    (
        collection,
        where.id (objID),
        modify.pull (fieldName, referenceID)
    );
    
    return new Resp();
}

@app.Route("/private/push/:collection/:obj_id/:fieldName/:reference_id")
@Encode()
Future<Resp> pushIdToList(@app.Attr() MongoDb dbConn, String collection, String obj_id, String fieldName, String reference_id) async
{
    var objID = StringToId(obj_id);
    var referenceID = StringToId(reference_id);
    
    await dbConn.update
    (
        collection, 
        where.id(objID),
        modify.push(fieldName, referenceID)
    );

    return new Resp();
}

@app.Route('/private/query/:collection', methods: const [app.POST])
@Secure(ADMIN)
queryCollection (@app.Attr() MongoDb dbConn, @app.Body(app.JSON) Map query, String collection)
{
    return dbConn.collection (collection)
            .find(query)
            .toList();
}

@app.Route('/private/modify/:collection/:id', methods: const [app.POST])
@Secure(ADMIN)
@Encode()
modifyCollection (@app.Attr() MongoDb dbConn, @app.Body(app.JSON) Map mod, String collection, String id) async
{
    try
    {

        await dbConn
            .collection (collection)
            .update
            (
                where.id(StringToId(id)),
                modify.set(mod['field'], mod['value'])
            );
        
        return new Resp();
    }
    catch (e, s)
    {
        return new Resp()
            ..error = e.toString() + s.toString();
    }  
}

@app.Route('/private/insert/:collection', methods: const [app.POST])
@Secure(ADMIN)
@Encode()
insertCollection (@app.Attr() MongoDb dbConn, String collection, String id) async
{
    try
    {
    
        var id = new ObjectId();
        
        
        await dbConn
            .collection (collection)
            .insert
            (
                { "_id" : id }
            );
        
        return new IdResp()
            ..id = id.toHexString();
    }
    catch (e, s)
    {
        return new IdResp()
            ..error = e.toString() + s.toString();
    }  
}
