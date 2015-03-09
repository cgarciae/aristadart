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
    
    Future<Vista> Get (String id)
    {
        return Requester.map (Method.GET, href).then(MapToVista);
    }
    
    Future<Vista> Update (Vista delta)
    {
        return Requester.privateJsonMap (Method.PUT, href, delta).then(MapToVista);
    }
    
    //Delete => DeleteGeneric
    
    static Vista MapToVista (Map map)
    {
        return Vista.MapToVista (decode, map);
    }
}