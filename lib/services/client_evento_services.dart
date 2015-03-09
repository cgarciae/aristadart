part of aristadart.client;

class ClientEventoServices extends ClientService<Evento>
{
    ClientEventoServices ([Evento source]) : super (source, Col.evento);
    
    Future<ListVistaResp> Vistas ()
    {
        return Requester.private
        (
            ListVistaResp, Method.GET, '$href/vistas'
        );
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