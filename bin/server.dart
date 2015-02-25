
import 'package:aristadart/arista.dart';

import 'arista_server.dart';

import 'dart:io';
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper_mongo/manager.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_static/shelf_static.dart';
import 'authorization.dart';
import 'dart:async';

main() async
{
    var _DOip = "104.131.109.228:8095";
    var _db = "dbtest";
    var _localIP = "192.168.59.103:8095";

    var partialDBHost = _localIP;
    
    var dbManager = new MongoDbManager("mongodb://${partialDBHost}/test", poolSize: 3);
    
    app.addPlugin(getMapperPlugin(dbManager));
    app.addPlugin(AuthorizationPlugin);
    
    app.setShelfHandler (createStaticHandler
    (
        "../web", 
        defaultDocument: "index.html",
        serveFilesOutsidePath: true
    ));
     
    app.setupConsoleLog();
    app.start(port: int.parse(partialHost.split(r':').last));
}

setDefaultAdmin ()
{
    
}



@app.Interceptor(r'/.*')
handleResponseHeader()
{
    if (app.request.method == "OPTIONS") 
    {
        //overwrite the current response and interrupt the chain.
        app.response = new shelf.Response.ok(null, headers: _createCorsHeader());
        app.chain.interrupt();
    } 
    else 
    {
        //process the chain and wrap the response
        app.chain.next(() => app.response.change(headers: _createCorsHeader()));
    }
}

@app.Interceptor (r'/private/.+')
authenticationFilter () 
{
    if (session["id"] == null)
    {
        app.chain.interrupt 
        (
            statusCode : HttpStatus.UNAUTHORIZED,
            responseValue : {"error": "NOT_AUTHENTICATED"}
        );
    } 
    else 
    {
        app.chain.next ();
    }
}

_createCorsHeader() => {"Access-Control-Allow-Origin": "*"};