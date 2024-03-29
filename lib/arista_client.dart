library aristadart.client;

import 'package:aristadart/arista.dart';

import 'dart:async';

import 'package:redstone_mapper/mapper.dart';
import 'package:angular/angular.dart';
import 'dart:html' as dom;

part 'components/evento/evento.dart';
part 'components/widgets/loader/loader.dart';
part 'components/widgets/acordeon/acordeon.dart';
part 'components/widgets/titulo_dinamico/titulo_dinamico.dart';
part 'components/vista/vista.dart';
part 'components/login/login.dart';
part 'components/login/nuevo_usuario.dart';
part 'components/home/home.dart';
part 'routing/router.dart';
part 'components/admin/admin.dart';
part 'components/admin/model.dart';
part 'components/admin/target.dart';

dom.Storage get storage => dom.window.localStorage;

String appendRequestParams (String path, Map<String,String> params)
{
    path += '?';
    for (String key in params.keys)
    {
        path += '${key}=${params[key]}&';
    }
    
    return path;
}

Future<dom.HttpRequest> makeRequest (String method, String path, 
                                    {dynamic data, Map headers, void onProgress (dom.ProgressEvent p), 
                                    String userId, Map<String,String> params})
{
    if (userId != null)
        addToHeaders(headers, {Header.authorization : userId});
    
    if (params != null)
        path = appendRequestParams(path, params);
    
    return dom.HttpRequest.request
    (
        path,
        method: method,
        requestHeaders: headers,
        sendData: data,
        onProgress: onProgress
    );
}

Future<String> requestString (String method, String path, {dynamic data, Map headers, 
                                void onProgress (dom.ProgressEvent p), String userId, Map<String,String> params})
{
    return makeRequest
    (
        method, path, data: data, headers: headers,
        onProgress: onProgress, userId: userId,
        params: params
    ) 
    .then ((dom.HttpRequest r) => r.responseText);
}

Future<dynamic> requestDecoded (Type type, String method, String path, {dynamic data, 
                                Map headers, void onProgress (dom.ProgressEvent p), 
                                String userId, Map<String,String> params})
{
    return requestString 
    (
        method, path, data: data, headers: headers, 
        onProgress: onProgress, userId: userId,
        params: params
    )   
    .then (decodeTo (type));
}

Future<dynamic> formRequestDecoded (Type type, String method, String path, dom.FormElement form, {Map headers, 
                                    void onProgress (dom.ProgressEvent p), String userId,
                                    Map<String,String> params})
{
    return requestDecoded
    (
        type, method, path, headers: headers,
        onProgress: onProgress, userId: userId,
        params: params, 
        data: new dom.FormData (form)
    );
}

/**
 * Hace un request al [path] enviando [obj] codificado a `JSON` y decodifica la respuesta al tipo [type]. 
 * 
 * [method] especifica el verbo http como `GET`, `PUT` o `POST`.
 */
Future<dynamic> jsonRequestDecoded (Type type, String method, String path, Object obj, 
                                    {Map headers, void onProgress (dom.ProgressEvent p), 
                                    String userId, Map<String,String> params})
{   
    return requestDecoded
    (
        type, method, path, data: encodeJson(obj),
        onProgress: onProgress, params: params,
        headers: addToHeaders
        (
            headers,
            {Header.contentType : ContType.applicationJson}
        )
    );
}


Map addToHeaders (Map headers, Map additions)
{
    //var contentType = {Header.contentType : ContType.applicationJson};
        
    if (headers != null)
        headers.addAll (additions);
    else
        headers = additions;
    
    return headers;
}

Future<Resp> saveInCollection (String collection, Object obj){
    return jsonRequestDecoded (Resp, Method.PUT, "private/$collection", obj);
}

Future<Resp> deleteFromCollection(String collection, String id){
    return requestDecoded(Resp, Method.DELETE, "private/$collection/$id");
}

Future<dynamic> newFromCollection (String collection, [Type type = IdResp])
{
    return requestDecoded (type, Method.POST, "private/$collection");
}

Future<dynamic> getFromCollection (Type tipo, String collection, String id)
{
    return requestDecoded (tipo, Method.GET, "private/$collection/$id");
}

Function doIfSuccess ([dynamic f (dynamic)])
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
            print (resp.error);
            return resp;
        }
    };
}

ifRespSuccess (Resp resp, Function f)
{
    if (resp.success)
    {
        if (f != null)
            return f (resp);
    }
    else
    {
        print (resp.error);
        return resp;
    }
}

Future<Resp> pushIDtoList (String collection, String objID, String fieldName, String referenceID)
{
    return requestDecoded(Resp, Method.GET,'/private/push/$collection/$objID/$fieldName/$referenceID');
}

Future<Resp> pullIDfromList (String collection, String objID, String fieldName, String referenceID)
{
    return requestDecoded(Resp, Method.GET,'/private/pull/$collection/$objID/$fieldName/$referenceID');
}

dom.FormElement getFormElement (dom.MouseEvent event) => (event.target as dom.ButtonElement).parent as dom.FormElement;

loginUser (Router router, UserAdminResp resp)
{
    storage['logged'] = resp.user.id;
    storage['admin'] = resp.user.admin.toString();
    router.go ('home', {});
}

@Injectable()
class MainController 
{
    bool abierto = true;
    String titulo = "";
    
    Router router;
    
    static MainController i;
    
    MainController (this.router)
    {
        i = this;
    }
    
    logout ()
    {
        return requestDecoded(Resp, Method.GET,'user/logout').then((Resp resp){
        
        if (resp.success)
        {
            router.go('login', {});
        }
        else
        {
            print("Logout Failed");
        }
        });
    }
            
    bool get isLoggedIn => loggedIn;
    


    go2home(){
        router.go('home',{});
    }
    
}

bool get loggedIn => storage['logged'] == true.toString();
bool get loggedAdmin => storage['admin'] == true.toString();
