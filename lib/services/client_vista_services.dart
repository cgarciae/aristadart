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
    
    
    
}