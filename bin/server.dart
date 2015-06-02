import 'package:aristadart/arista.dart';

import 'arista_server.dart';

import 'dart:io';
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper_mongo/manager.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_static/shelf_static.dart';
import 'package:di/di.dart';
import 'utils/utils.dart';
import 'dart:async';
import 'package:logging/logging.dart';

main() async {
  var con = "mongodb://${partialDBHost}/test";
  var dbManager = new MongoDbManager(con, poolSize: 3);

  app.addPlugin(getMapperPlugin(dbManager));
  app.addPlugin(AuthenticationPlugin);
  app.addPlugin(ErrorCatchPlugin);

  app.addModule(new Module()
    ..bind(EventoServices)
    ..bind(UserServices)
    ..bind(ObjetoUnityServices)
    ..bind(User));
  

  app.setShelfHandler(createStaticHandler("web",
      defaultDocument: "index.html", serveFilesOutsidePath: true));

  app.setupConsoleLog(Level.ALL);
  await app.start(port: port, autoCompress: true);

  MongoDb dbConn = await dbManager.getConnection();

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

@app.Interceptor(r'/private/.+')
authenticationFilter() {
  print(app.request.headers);
  if (session["id"] == null) {
    app.chain.interrupt(
        statusCode: HttpStatus.UNAUTHORIZED,
        responseValue: {"error": "NOT_AUTHENTICATED"});
  } else {
    app.chain.next();
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
