part of aristadart.client;

abstract class Requester
{
    static Future<dom.HttpRequest> make (String method, String path, 
                                        {dynamic data, Map headers, void onProgress (dom.ProgressEvent p), 
                                        String userId, Map<String,dynamic> params})
    {
        
        if (userId != null)
            headers = addOrSet(headers, {HeaderType.authorization : userId});
        
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
    
    static Future<String> string (String method, String path, {dynamic data, Map headers, 
                                    void onProgress (dom.ProgressEvent p), String userId, Map<String,dynamic> params})
    {
        
        return make
        (
            method, path, data: data, headers: headers,
            onProgress: onProgress, userId: userId,
            params: params
        ) 
        .then ((dom.HttpRequest r) {
            
            //print (r.responseText);
            return r.responseText;
        });
    }
    
    static Future map (String method, String path, {dynamic data, Map headers, 
                                void onProgress (dom.ProgressEvent p), String userId, Map<String,dynamic> params})
    {
        return string
        (
            method, path, data: data, headers: headers,
            onProgress: onProgress, userId: userId,
            params: params
        ) 
        .then (JSON.decode);
    }
    
    static Future privateMap (String method, String path, {dynamic data, Map headers, 
                                    void onProgress (dom.ProgressEvent p), Map<String,dynamic> params})
    {
        return map
        (
            method, path, data: data, headers: headers,
            onProgress: onProgress, userId: userId,
            params: params
        );
    }
    
    static Future jsonMap (String method, String path, Object obj, {Map headers, 
                                    void onProgress (dom.ProgressEvent p), String userId, Map<String,dynamic> params})
    {
        return map
        (
            method, path, data: encodeJson(obj),
            onProgress: onProgress, userId: userId,
            params: params, headers: addOrSet
            (
                headers,
                {HeaderType.contentType : ContType.applicationJson}
            )
        );
    }
    
    static Future privateJsonMap (String method, String path, Object obj, {Map headers, 
                                    void onProgress (dom.ProgressEvent p), Map<String,dynamic> params})
    {
        return jsonMap
        (
            method, path, obj, headers: headers,
            onProgress: onProgress, userId: userId,
            params: params
        );
    }
    
    //TODO: privateJsonMap

    static Future<dynamic> decoded (Type type, String method, String path, {dynamic data, 
                                    Map headers, void onProgress (dom.ProgressEvent p), 
                                    String userId, Map<String,dynamic> params})
    {
        return string
        (
            method, path, data: data, headers: headers, 
            onProgress: onProgress, userId: userId,
            params: params
        )   
        .then (decodeTo (type));
    }
    
    static Future<dynamic> private (Type type, String method, String path, {dynamic data, 
                                    Map headers, void onProgress (dom.ProgressEvent p), 
                                    Map<String,dynamic> params})
    {
        return decoded
        (
            type, method, path, data: data, headers: headers, 
            onProgress: onProgress, params: params,
            userId: userId
        );
    }
    


    static Future<dynamic> form (Type type, String method, String path, dom.FormElement form, {Map headers, 
                                        void onProgress (dom.ProgressEvent p), String userId,
                                        Map<String,dynamic> params})
    {
        return decoded
        (
            type, method, path, headers: headers,
            onProgress: onProgress, userId: userId,
            params: params, 
            data: new dom.FormData (form)
        );
    }
    
    static Future<dynamic> privateForm (Type type, String method, String path, dom.FormElement form, {Map headers, 
                                    void onProgress (dom.ProgressEvent p),
                                    Map<String,dynamic> params})
    {
        return Requester.form
        (
            type, method, path, form, headers: headers,
            onProgress: onProgress,
            params: params,
            userId: userId
        );
    }
    

/**
 * Hace un request al [path] enviando [obj] codificado a `JSON` y decodifica la respuesta al tipo [type]. 
 * 
 * [method] especifica el verbo http como `GET`, `PUT` o `POST`.
 */
    static Future<dynamic> json (Type type, String method, String path, Object obj, 
                                        {Map headers, void onProgress (dom.ProgressEvent p), 
                                        String userId, Map<String,dynamic> params})
    {   
        return decoded
        (
            type, method, path, data: encodeJson(obj),
            onProgress: onProgress, params: params,
            userId: userId, headers: addOrSet
            (
                headers,
                {HeaderType.contentType : ContType.applicationJson}
            )
        );
    }
    

    /**
     * Hace un request al [path] enviando [obj] codificado a `JSON` y decodifica la respuesta al tipo [type]. 
     * 
     * [method] especifica el verbo http como `GET`, `PUT` o `POST`.
     */
    static Future<dynamic> privateJson (Type type, String method, String path, Object obj, 
                                {Map headers, void onProgress (dom.ProgressEvent p), 
                                Map<String,dynamic> params})
    {   
        return json
        (
            type, method, path, obj,
            onProgress: onProgress, params: params,
            userId: userId
        );
    }
}