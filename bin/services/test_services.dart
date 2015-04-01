part of aristadart.server;

abstract class Vista2 extends Ref
{
    String get icon;
}

class Const2 extends Ref implements Vista2
{
    @Field() String get icon => "algo";
    @Field() String get href => "someHost/$id"; 
}



@app.Route ('/testStream')
testSream ()
{
    StreamController<String> controller = new StreamController<String> ();
    
    () async
    {
        var initialTime = new DateTime.now();
        
        await new Future.delayed (new Duration (seconds: 1));
        controller.add("hello\n");
        
        await new Future.delayed (new Duration (seconds: 10));
        controller.add("chao\n");
        
        var finalTime = new DateTime.now().difference(initialTime);
        
        controller.add(finalTime.toString());
        
        controller.close();
    
    }();
    
    Stream<List<int>> intStream = controller.stream.map((s) => s.codeUnits);
    
    return new shelf.Response.ok (intStream);
}

@app.Group ('/testdi')
@Encode()
class TestDi
{
    User user;
    
    TestDi (User this.user);
    
    @app.DefaultRoute()
    testDi () => user..nombre = "Cristian";
}


@app.Route ('/poly')
@Encode()
testPoly ()
{
    var inst = new Const2()
        ..id = "some id";
    
    return inst;
}


@app.Route ('*', matchSubPaths: true)
anyPath()
{
    var path = app.request.url;
    //Do something with path
}


@app.Route ('/testOptional/:mandatory')
testOptional (String mandatory, {@app.QueryParam() String optional}) => "$mandatory $optional";


@app.Route ('/testQuery')
testQuery (@app.QueryParam('algo') String algo, @app.QueryParam('mas') String mas) => "$algo $mas";

@app.Route ('/testVuforiaImage', methods: const[app.POST], allowMultipartRequest: true)
@Encode()
Future<VuforiaResponse> testVuforiaImage (@app.Body(app.FORM) Map form) async
{
    HttpBodyFileUpload file = FormToFileUpload(form);
    
    return VuforiaServices.newImage(file.content, newId());
}

@app.Route ('/updateVuforiaImage/:id', methods: const[app.PUT], allowMultipartRequest: true)
@Encode()
Future<VuforiaResponse> updateVuforiaImage (String id, @app.Body(app.FORM) Map form) async
{
    
    HttpBodyFileUpload file = FormToFileUpload(form);
    
    return VuforiaServices.updateImage(id, file.content);
}

@app.Route ('/testOverride')
@Encode()
testOverride () async
{
    
    var id = newId();
    
    VuforiaResponse resp = new VuforiaResponse()
        ..result_code = "Success"
        ..id = id;
    
    var col = 'testVuforia';
    
    await db.insert(col, resp);
    
    var delta = new VuforiaResponse()
        ..target_record = (new VuforiaTargetRecord()
                ..width = 2);
        
    
    await db.update
    (
        col,
        where.id(StringToId(id)),
        delta,
        override: false
    );
    
    return db.findOne (col, VuforiaResponse, where.id(StringToId(id)));
}

@Encode()
@Catch()
@app.Route ('/testErro1/:n')
testError1 (int n) async
{
    print ("hola");
    var resp = await testError2(n);
    return resp;
}

@app.Route ('/testErro2')
@Encode()
testError2 (int n) async
{
    await db.find(Col.cloudTarget, Resp);
    
    if (n != 1)
        throw new Exception ("invalid id");
    
    return new BoolResp()
        ..value = true;
}

@app.Route ('/testPrivate')
@Private()
testPrivate () => "funciona";

@app.Route("/test")
@Encode()
gridFSTest(@app.Attr() MongoDb dbConn)
{
    var gridFS = new GridFS (dbConn.innerConn);
    var input = new File ('../web/test/file.txt').openRead();
    var gridIn = gridFS.createFile (input, 'file.txt');
    
    return gridIn.save()
            .then((res) => gridFS.getFile('file.txt'))
            .then((GridOut gridOut) => gridOut.writeToFilename('../web/test/file_out.txt'))
            .then((_) =>
                new IdResp()
                    ..id = gridIn.id.toHexString()
            );
}

@app.Route("/test/files")
gridFSTestFiles(@app.Attr() MongoDb dbConn)
{
    var gridFS = new GridFS (dbConn.innerConn);

    return gridFS.chunks.find().toList().then((List<Map> list)
    {
        list.forEach (print);
        
        return list.toString();
    });
}



@app.Route('/esteban', methods: const [app.POST])
@Encode()
testEsteban (@app.Attr() MongoDb dbConn, @Decode() User usuario) async
{ 
    usuario.id = new ObjectId().toHexString();
    await dbConn.insert(Col.user, usuario);
    
    return new IdResp()
        ..id = usuario.id;
}



