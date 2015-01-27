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
part 'components/vista/vista.dart';
part 'components/login/login.dart';
part 'components/login/nuevo_usuario.dart';
part 'components/home/home.dart';
part 'routing/router.dart';

dom.Storage get storage => dom.window.localStorage;



class ReqParam
{
    String field;
    String value;
    
    ReqParam (this.field, this.value);
    
    String get formula => field + '=' + value;
}

String reduceParams (List<ReqParam> params) =>  params.fold('?', (String acum, ReqParam elem) => (acum == '?' ? acum : acum + '&') + elem.formula);

Future<dom.HttpRequest> makeRequest (String method, String path, [Object data])
{
    if (data == null)
    {
        return dom.HttpRequest.request
        (
            path,
            method: method
        );
    }
    else
    {
        return dom.HttpRequest.request
        (
            path,
            method: method,
            sendData: data
        ); 
    } 
}

Future<dynamic> requestString (String method, String path, [Object data])
{
    return makeRequest (method, path, data) 
    .then (getField (#responseText));
}

Future<dynamic> requestDecoded (Type type, String method, String path, [Object data])
{
    return requestString (method, path, data)   
    .then (decodeTo (type));
}

Future<dynamic> requestQueryMap (String method, String path, [Object data])
{
    return requestString (method, path, data)
    .then (JSON.decode)
    .then (MapToQueryMap);
}

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

Future<dynamic> jsonRequestDecoded (String path, Object obj, Type responseType)
{
    return jsonRequestString(path, obj)
    .then((json) => decodeJson(json, responseType));
}



Future<dom.HttpRequest> formRequest (String path, dom.FormElement form)
{
    
    return dom.HttpRequest.request (path,
            method: "POST", 
            sendData: new dom.FormData (form));
}

Future<dynamic> formRequestDecoded (String path, dom.FormElement form, Type responseType)
{
    return formRequest(path, form).then((dom.HttpRequest req)
    {
        return decodeJson(req.responseText, responseType);
    });      
}

Future<Resp> saveInCollection (String collection, Object obj)
{
    return jsonRequestDecoded('private/save/$collection', obj, Resp);
}

Future<dynamic> getFromCollection (Type type, String collection, String id)
{
    return getRequestDecoded(type, 'private/get/$collection/$id');
}

Function doIfSuccess ([Function f])
{
    return (dynamic resp)
    {
        if (resp.success)
        {
            if (f != null)
                return f (resp);
        }
        else
        {
            dom.window.alert(resp.error);
        }
    };
}

Future<Resp> pushIDtoList (String collection, String objID, String fieldName, String referenceID)
{
    return getRequestDecoded (Resp, '/private/push/$collection/$objID/$fieldName/$referenceID');
}

Future<Resp> pullIDfromList (String collection, String objID, String fieldName, String referenceID)
{
    return getRequestDecoded (Resp, '/private/pull/$collection/$objID/$fieldName/$referenceID');
}

Future<Resp> deleteFromCollection (String collection, String id)
{
    return getRequestDecoded(Resp, '/private/delete/$collection/$id');
}

Future<IdResp> newFromCollection (String collection)
{
    return getRequestDecoded(IdResp, '/private/new/$collection');
}