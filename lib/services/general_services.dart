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
upload(@app.Body(app.FORM) Map form)
{
    
    print (form);
    
    HttpBodyFileUpload f = form['file'];
    
    print (f);
    
    print (f.runtimeType);
    
    print (f.filename);
    
    return new Directory(('../web/images/uploads')).create(recursive: true).then((Directory dir)
    {
        var url = '${dir.path}/${f.filename}';
        
        return new File(url).writeAsBytes(f.content)
                .then((_) => url.replaceAll('../web/', ''));
    })
    .then((String urlCorregida)
    {
        return new UrlResp()
            ..success = (form != null)
            ..url = urlCorregida;
    });
}

@app.Route('/write')
@Encode()
writeFile()
{
    final string = 'Dart!';

    var encodedData = UTF8.encode(string);

    return new Directory(('../web/test')).create(recursive: true).then((Directory dir)
    {
        return new File('${dir.path}/file.txt')
            .writeAsBytes(encodedData);
    })
    .then((File file) => file.readAsBytes())
    .then((data) 
    {
      // Decode to a string, and print.
      print(UTF8.decode(data)); // Prints 'Dart!'.
    })
    .then((_)
    {
        return new Resp()
            ..success = true;
    });
    
}
