part of aristadart.client;

class ClientVistaServices extends ClientService<Vista>
{
    ClientVistaServices ([Vista source]) : super (source, Col.vista);
    
    Future<Vista> New ({int typeNumber, String eventoId})
    {
        Map params = {};
        
        if (typeNumber != null)
            params["type"] = typeNumber;
        
        if (eventoId != null)
            params["eventoId"] = eventoId;
        
        return Requester.privateMap
        (
            Method.POST, pathBase, params: params
        )
        .then(MapToVista);
    }
    
    Future<Vista> Get ()
    {
        return Requester.map (Method.GET, href).then(MapToVista);
    }
    
    Future<Vista> Update (Vista delta)
    {
        return Requester.privateJsonMap (Method.PUT, href, delta).then(MapToVista);
    }
    
    Future<Vista> SetType (int type)
    {
        return Requester.privateMap(Method.PUT, '$href/setType',params: {'type': type})
                        .then(MapToVista);
    }
    
    //Delete => DeleteGeneric
    
    static Vista MapToVista (Map map)
    {
        return Vista.MapToVista (decode, map);
    }
    
    static Vista StringToVista (String json)
    {
        return Vista.MapToVista (decode, JSON.decode(json));
    }
}