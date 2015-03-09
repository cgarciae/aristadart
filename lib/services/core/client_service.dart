part of aristadart.client;

abstract class ClientService<T extends Ref>
{
    final T source;
    final String pathBase;
    
    String get href => source.href;
    
    ClientService (this.source, this.pathBase);
    
    
    ////////////////
    //BASIC METHODS
    ////////////////
    
    Future<T> NewGeneric ()
    {
        return private
        (
            Method.POST,
            pathBase
        );
    }
    
    Future<T> GetGeneric ()
    {
        return private
        (
            Method.GET,
            source.href
        );
    }
    
    Future<T> UpdateGeneric (T delta)
    {
        return privateJson
        (
            Method.PUT,
            source.href,
            delta
        );
    }
    
    Future<DbObj> DeleteGeneric ()
    {
        return Requester.private
        (
            DbObj,
            Method.DELETE,
            source.href
        );
    }
    
    ////////////////
    //Requests
    ////////////////
    
    Future<T> decoded (String method, String path, {dynamic data, 
        Map headers, void onProgress (dom.ProgressEvent p), 
        String userId, Map<String,String> params})
    {
        return Requester.decoded
        (
            T, method, path, data: data, headers: headers,
            onProgress: onProgress, userId: userId, params: params
        );
    }
    
    Future<T> private (String method, String path, {dynamic data, 
                            Map headers, void onProgress (dom.ProgressEvent p), 
                            Map<String,String> params})                      
    {
        return Requester.private
        (
            T, method, path, data: data, headers: headers,
            onProgress: onProgress, params: params
        );
    }
    
    Future<T> form (String method, String path, dom.FormElement form, {Map headers, 
                            void onProgress (dom.ProgressEvent p), String userId,
                            Map<String,String> params})
    {
        return Requester.form
        (
            T, method, path, form, headers: headers,
            onProgress: onProgress,userId: userId,
            params: params
        );
    }
    
    Future<T> privateForm (String method, String path, dom.FormElement form, {Map headers, 
                            void onProgress (dom.ProgressEvent p),
                            Map<String,String> params})
    {
        return this.form 
        (
           method, path, form, headers: headers,
           onProgress: onProgress, params: params,
           userId: userId 
        );
    }
    
    Future<T> json (String method, String path, T obj, 
                    {Map headers, void onProgress (dom.ProgressEvent p), 
                    String userId, Map<String,String> params})
    {   
        return Requester.json
        (
            T, method, path, obj, headers: headers,
            onProgress: onProgress, userId: userId,
            params: params
        );
    }
    
    Future<T> privateJson (String method, String path, T obj, 
                                    {Map headers, void onProgress (dom.ProgressEvent p), 
                                    Map<String,String> params})
    {   
        return json
        (
            method, path, obj, headers: headers,
            onProgress: onProgress, params: params,
            userId: userId
        );
    }
}