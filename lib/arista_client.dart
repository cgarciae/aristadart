library arista_client;

import 'dart:async';
import 'dart:convert';
import 'package:aristadart/arista.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:angular/angular.dart';
import 'dart:html' as dom;
import 'package:redstone/query_map.dart';
import 'package:fp/fp.dart';

part 'components/evento/evento.dart';
part 'components/view/view.dart';
part 'components/login/login.dart';
part 'components/home/home.dart';
part 'routing/router.dart';

get storage => dom.window.localStorage;

class ReqParam
{
    String field;
    String value;
    
    ReqParam (this.field, this.value);
    
    String get formula => field + '=' + value;
}

String reduceParams (List<ReqParam> params) =>  params.fold('?', (String acum, ReqParam elem) => (acum == '?' ? acum : acum + '&') + elem.formula);

Future<String> getRequestString (String path, [List<ReqParam> params = const []])
{
    var paramString = reduceParams(params);
    
    return dom.HttpRequest.getString(path + paramString);
}

Future<dom.HttpRequest> getRequest (String path, [List<ReqParam> params = const []])
{
    var paramString = reduceParams(params);
    
    return dom.HttpRequest.request(path + paramString, method: "GET");
}

Future<QueryMap> getRequestQueryMap (String path, [List<ReqParam> params = const []])
{
    return getRequest(path, params)
    .then((dom.HttpRequest req) => new QueryMap (JSON.decode (req.responseText)));
}

Future<dynamic> getRequestDecoded (Type type, String path, [List<ReqParam> params = const []])
{
    return getRequestString(path, params)
    .then((json) => decodeJson(json, type));
}

Future<dom.HttpRequest> jsonRequest (String path, Object obj)
{
    return dom.HttpRequest.request(path, method: "POST", 
            requestHeaders: {"content-type": "application/json"}, 
            sendData: encodeJson(obj));
            
}

Future<Object> jsonRequestObject (String path, Object obj)
{
    return jsonRequest (path, obj)
    .then((dom.HttpRequest req){
        return req.response;
    });
}


Future<String> jsonRequestString (String path, Object obj)
{
    return jsonRequest (path, obj)
    .then((dom.HttpRequest req){
        return req.responseText;
    });
}



Future<Map> jsonRequestJSON (String path, Object obj)
{
    return jsonRequestString (path, obj)
    .then(JSON.decode);
}

Future<QueryMap> jsonRequestQueryMap (String path, Object obj)
{
    return jsonRequestJSON (path, obj)
    .then((Map m) => new QueryMap (m));
}

Future<dynamic> jsonRequestDecoded (String path, Object obj, Type type)
{
    return jsonRequestString(path, obj)
    .then((json) => decodeJson(json, type));
}