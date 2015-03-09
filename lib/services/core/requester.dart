part of aristadart.client;

abstract class Requester
{
    static Future<dom.HttpRequest> make (String method, String path, 
                                        {dynamic data, Map headers, void onProgress (dom.ProgressEvent p), 
                                        String userId, Map<String,String> params})
    {
        
        if (userId != null)
            headers = addOrSet(headers, {Header.authorization : userId});
        
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
                                    void onProgress (dom.ProgressEvent p), String userId, Map<String,String> params})
    {
        return make
        (
            method, path, data: data, headers: headers,
            onProgress: onProgress, userId: userId,
            params: params
        ) 
        .then ((dom.HttpRequest r) => r.responseText);
    }
    
    static Future<Map> map (String method, String path, {dynamic data, Map headers, 
                                void onProgress (dom.ProgressEvent p), String userId, Map<String,String> params})
    {
        return string
        (
            method, path, data: data, headers: headers,
            onProgress: onProgress, userId: userId,
            params: params
        ) 
        .then (JSON.decode);
    }
    
    static Future<Map> privateMap (String method, String path, {dynamic data, Map headers, 
                                    void onProgress (dom.ProgressEvent p), Map<String,String> params})
    {
        return map
        (
            method, path, data: data, headers: headers,
            onProgress: onProgress, userId: userId,
            params: params
        );
    }
    
    static Future<Map> jsonMap (String method, String path, {Object data, Map headers, 
                                    void onProgress (dom.ProgressEvent p), String userId, Map<String,String> params})
    {
        return map
        (
            method, path, data: encodeJson(data), headers: headers,
            onProgress: onProgress, userId: userId,
            params: params
        );
    }
    
    //TODO: privateJsonMap

    static Future<dynamic> decoded (Type type, String method, String path, {dynamic data, 
                                    Map headers, void onProgress (dom.ProgressEvent p), 
                                    String userId, Map<String,String> params})
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
                                    Map<String,String> params})
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
                                        Map<String,String> params})
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
                                    Map<String,String> params})
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
                                        String userId, Map<String,String> params})
    {   
        return decoded
        (
            type, method, path, data: encodeJson(obj),
            onProgress: onProgress, params: params,
            userId: userId, headers: addOrSet
            (
                headers,
                {Header.contentType : ContType.applicationJson}
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
                                Map<String,String> params})
    {   
        return json
        (
            type, method, path, obj,
            onProgress: onProgress, params: params,
            userId: userId
        );
    }
}