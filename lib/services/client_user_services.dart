part of aristadart.client;

class ClientUserServices extends ClientService<User>
{
    ClientUserServices (User source) : super (source, "user");
    
    Future<User> NewOrLogin ()
    {
        return json (Method.POST, pathBase, source);
    }
    
    Future<BoolResp> IsAdmin ()
    {
        return Requester.private (BoolResp, Method.GET, '$href/isAdmin');
    }
    
    Future<ListEventoResp> Eventos ()
    {
        return Requester.private
        (
            ListEventoResp, Method.GET, '$href/eventos'
        );
    }
}