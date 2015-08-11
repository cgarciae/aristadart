import 'package:aristadart/arista.dart';

import 'arista_server.dart';

import 'dart:io';
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper_mongo/manager.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_static/shelf_static.dart';
import 'package:redstone/query_map.dart';
import 'package:di/di.dart';
import 'utils/utils.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;

main() async {
  var con = "mongodb://${partialDBHost}/test";
  var dbManager = new MongoDbManager(con, poolSize: 3);

  app.addPlugin(getMapperPlugin(dbManager));
  app.addPlugin(AuthenticationPlugin);
  app.addPlugin(ErrorCatchPlugin);
  app.addPlugin(headersPlugin);

  app.addModule(new Module()
    ..bind(EventoServices)
    ..bind(VistaServices)
    ..bind(UserServices)
    ..bind(FileServices)
    ..bind(ObjetoUnityServices)
    ..bind(VistaServices)
    ..bind(CloudTargetServices)
    ..bind(LocalImageTargetServices)
    ..bind(User)
    ..bind(MongoDb, toValue: null));

  app.setShelfHandler(createStaticHandler(staticFolder,
      defaultDocument: "index.html", serveFilesOutsidePath: true));

  app.setupConsoleLog();
  await app.start(port: port, autoCompress: true);

  MongoDb dbConn = await dbManager.getConnection();

  //TODO: Remove
  //await dbConn.innerConn.drop();

  print("Got connection");

  User user = await dbConn.findOne(Col.user, User, where.eq('admin', true));

  if (user == null) {
    print("Creando nuevo admin");
    if (tipoBuild == TipoBuild.deploy) {
      var newUser = new ProtectedUser()
        ..nombre = "Arista"
        ..apellido = "Dev"
        ..email = "info@aristadev.com"
        ..money = 1000000000
        ..admin = true;

      await dbConn.insert(Col.user, newUser);
    } else {
      var newUser = new ProtectedUser()
        ..nombre = "Arista"
        ..apellido = "Dev"
        ..email = "a"
        ..money = 1000000000
        ..admin = true;

      await dbConn.insert(Col.user, newUser);
    }
  } else {
    print("Admin found:");
    print(user.email);
  }

  //List users = await dbConn.collection (Col.user).find().toList();
  //users.forEach (print);

  user = await dbConn.findOne(
      Col.user, User, where.eq("email", "cgarcia.e88@gmail.com"));

  if (user == null) {
    var cristian = new ProtectedUser()
      ..id = newId()
      ..nombre = "Cristian"
      ..apellido = "Garcia"
      ..email = "cgarcia.e88@gmail.com"
      ..money = 1000000000
      ..admin = true;

    await dbConn.insert(Col.user, cristian);

    print("Usuario Cristian Creado");
  } else {
    print("Cristian ya existe");
  }

  //Set default model is none exists
  var injector = new ModuleInjector([
    new Module()
      ..bind(EventoServices)
      ..bind(VistaServices)
      ..bind(UserServices)
      ..bind(FileServices)
      ..bind(ObjetoUnityServices)
      ..bind(VistaServices)
      ..bind(CloudTargetServices)
      ..bind(LocalImageTargetServices)
      ..bind(User)
      ..bind(MongoDb, toValue: dbConn)
  ]);

  ObjetoUnityServices objetoUnityServices = injector.get(ObjetoUnityServices);
  LocalImageTargetServices localImageTargetServices =
      injector.get(LocalImageTargetServices);
  EventoServices eventoServices = injector.get(EventoServices);
  UserServices userServices = injector.get(UserServices);
  FileServices fileServices = injector.get(FileServices);
  VistaServices vistaServices = eventoServices.vistaServices;

  ObjetoUnity obj = await objetoUnityServices.findOne();
  LocalImageTarget localImageTarget = await localImageTargetServices.findOne();
  Evento evento = await eventoServices.findOne();

  String cristianId =
      (await userServices.findOne({"email": "cgarcia.e88@gmail.com"})).id;
  var googleDriveHost = "http://www.googledrive.com/host";

  if (obj == null) {
    var urlWindows = "$googleDriveHost/0BxT_o5tB1SPXdTdSVlR4NGwzMGM";
    var urlAndroid = "$googleDriveHost/0BxT_o5tB1SPXaVZDdU9DTXdHeWM";

    http.Response respWindows = await http.get(urlWindows);
    http.Response respAndroid = await http.get(urlAndroid);

    ObjetoUnity objetoUnity = await objetoUnityServices.New(cristianId);

    await objetoUnityServices.UpdateModels(objetoUnity.id, new QueryMap({})
      ..android = new app.HttpBodyFileUpload(
          ContentType.BINARY, "android", respAndroid.bodyBytes)
      ..windows = new app.HttpBodyFileUpload(
          ContentType.BINARY, "windows", respWindows.bodyBytes)
      ..ios = new app.HttpBodyFileUpload(
          ContentType.BINARY, "ios", respAndroid.bodyBytes)
      ..osx = new app.HttpBodyFileUpload(
          ContentType.BINARY, "osx", respWindows.bodyBytes));

    await objetoUnityServices.Update(objetoUnity.id, new ObjetoUnity()
      ..tags = ["cube", "piso"]
      ..name = "Modelo Test"
      ..public = true);

    objetoUnity = await objetoUnityServices.Publish(objetoUnity.id);

    print(encode(objetoUnity));
  }

  if (localImageTarget == null) {
    var ulrXML = "$googleDriveHost/0BxT_o5tB1SPXbXJ0NjF6M04wU2s";
    var urlDat = "$googleDriveHost/0BxT_o5tB1SPXT3BFSEtwM0M1TEU";
    var urlImagenPreview = "$googleDriveHost/0BxT_o5tB1SPXdGR5VFpXZmUyUGs";

    http.Response respImagen = await http.get(urlImagenPreview);
    http.Response respXML = await http.get(ulrXML);
    http.Response respDat = await http.get(urlDat);

    localImageTarget = await localImageTargetServices.New(cristianId);

    await localImageTargetServices.UpdateFiles(localImageTarget.id,
        new QueryMap({})
      ..xml =
      new app.HttpBodyFileUpload(ContentType.BINARY, "xml", respXML.bodyBytes)
      ..dat =
      new app.HttpBodyFileUpload(ContentType.BINARY, "dat", respDat.bodyBytes));

    await localImageTargetServices.NewOrUpdateUserFile(localImageTarget.id,
        new QueryMap({
      "imagen": new app.HttpBodyFileUpload(
          ContentType.parse("image"), "imagen", respImagen.bodyBytes)
    }), new FileDb()..filename = "imagen");

    localImageTarget = await localImageTargetServices.Update(
        localImageTarget.id, new LocalImageTarget()
      ..name = "Local Target Test"
      ..public = true);

    localImageTarget =
        await localImageTargetServices.Publish(localImageTarget.id);

    print(encode(localImageTarget));
  }

  if (evento == null) {
    evento = await eventoServices.New(cristianId);

    var urlImagenPreview = "$googleDriveHost/0BxT_o5tB1SPXdGR5VFpXZmUyUGs";
    http.Response respXML = await http.get(urlImagenPreview);
    var fileDb = new FileDb()
      ..owner = (new User()..id = cristianId)
      ..filename = "imagen-preview";
    var bodyUpload = new app.HttpBodyFileUpload(
        ContentType.BINARY, "imagen-preview", respXML.bodyBytes);

    fileDb = await fileServices.NewOrUpdate(
        {"imagenPreview": bodyUpload}, fileDb, ownerId: cristianId);

    evento = await eventoServices.Update(evento.id, new Evento()
      ..nombre = "Evento Prueba"
      ..demo = true
      ..descripcion = "Este es un evento de prueba"
      ..imagenPreview = fileDb);

    ConstruccionRA vista =
        await vistaServices.New(1, evento.id, userId: cristianId);

    LocalImageTarget localTarget =
        await localImageTargetServices.findOne({"public": true});
    ObjetoUnity objetoUnity =
        await objetoUnityServices.findOne({"public": true});

    vista = await vistaServices.Update(vista.id, encode(new ConstruccionRA()
      ..localTarget = (new LocalImageTarget()..id = localTarget.id)
      ..objetoUnity = (new ObjetoUnity()..id = objetoUnity.id)));
  }

  //Close connection
  dbManager.closeConnection(dbConn);
}

@app.Interceptor(r'/.*')
handleResponseHeader() {
  if (app.request.method == "OPTIONS") {
    //overwrite the current response and interrupt the chain.
    app.response = new shelf.Response.ok(null, headers: _specialHeaders());
    app.chain.interrupt();
  } else {
    //process the chain and wrap the response
    app.chain.next(() => app.response.change(headers: _specialHeaders()));
  }
}


_specialHeaders() {
  var cross = {"Access-Control-Allow-Origin": "*"};

  if (tipoBuild <= TipoBuild.jsTesting) {
    cross['Cache-Control'] =
        'private, no-store, no-cache, must-revalidate, max-age=0';
  }

  return cross;
}
