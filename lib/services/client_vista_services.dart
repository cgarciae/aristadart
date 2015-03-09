part of aristadart.client;

class ClientVistaServices extends ClientService<Vista>
{
    ClientVistaServices ([Vista source]) : super (source, Col.evento);
    
    Future<Vista> New (int typeNumber, String eventoId)
    {
        return Requester.privateMap
        (
            Method.POST, pathBase, params: {"type": typeNumber, "eventoId": eventoId}
        )
        .then(MapToVista);
    }
    
    Future<Vista> Get (String id)
    {
        return Requester.map (Method.GET, href).then(MapToVista);
    }
    
    static Vista MapToVista (Map map)
    {
        return Vista.MapToVista (decode, map);
    }
}