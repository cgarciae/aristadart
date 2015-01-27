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