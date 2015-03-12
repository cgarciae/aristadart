part of aristadart.client;

class ClientEventoServices extends ClientService<Evento>
{
    ClientEventoServices ([Evento source]) : super (source, Col.evento);
    
    Future<List<Vista>> Vistas ()
    {
        return Requester.privateMap
        (
            Method.GET, '$href/vistas'
        )
        .then ((List<Map> list) {
            print (list);
            return list.map(ClientVistaServices.MapToVista).toList();
            });
    }
    
    Future<Evento> AddVista (String vistaId)
    {
        return private (Method.POST, '$href/addVista/$vistaId');
    }
    
    Future<Evento> RemoveVista (String vistaId)
    {
        return private  (Method.PUT, '$href/removeVista/$vistaId');
    }
    
    
}