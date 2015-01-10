
import 'package:aristadart/arista.dart';

import '../lib/arista_server.dart';

import 'dart:io';
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/mapper_factory.dart';
import 'package:redstone_mapper_mongo/manager.dart';
import 'package:redstone/query_map.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_static/shelf_static.dart';
import '../lib/authorization.dart';


main() 
{
  
    var DOip = "104.131.109.228:8095";
    var db = "db";
    var localIP = "192.168.59.103:8095";
  
    var dbManager = new MongoDbManager("mongodb://${localIP}/test", poolSize: 3);

    app.addPlugin(getMapperPlugin(dbManager));
    app.addPlugin(AuthorizationPlugin);
  
    app.setShelfHandler (createStaticHandler
    (
        "../web", 
        defaultDocument: "index.html",
        serveFilesOutsidePath: true
    ));
  
  app.setupConsoleLog();
  app.start(port: 9090);
}

//redstone_mapper will create a "dbConn" attribute
//for every request.
@app.Route("/mongo")
listUsers(@app.Attr() MongoDb dbConn) 
{
    dbConn.innerConn.collection("s");
    
    return dbConn.collection("s").insert({"s":"chao"}).then((_) {
    return dbConn.collection("s").find().toList();
    });
    
    
}

@app.Route("/hola")
hello(@app.Attr() MongoDb dbConn) => "Hola Mateo!!";

@app.Route("/chao")
chao(@app.Attr() MongoDb dbConn) => "CHAOOOO";

@app.Interceptor(r'/.*')
handleResponseHeader() {
  if (app.request.method == "OPTIONS") {
    //overwrite the current response and interrupt the chain.
    app.response = new shelf.Response.ok(null, headers: _createCorsHeader());
    app.chain.interrupt();
  } else {
    //process the chain and wrap the response
    app.chain.next(() => app.response.change(headers: _createCorsHeader()));
  }
}

@app.Interceptor(r'/private/.+')
authenticationFilter() {
  if (app.request.session["user"] == null) {
    app.chain.interrupt(statusCode: HttpStatus.UNAUTHORIZED, responseValue: {"error": "NOT_AUTHENTICATED"});
  } else {
    app.chain.next();
  }
}

_createCorsHeader() => {"Access-Control-Allow-Origin": "*"};