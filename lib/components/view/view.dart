part of arista_client;

@Component
(
    selector : "evento",
    templateUrl: 'components/evento/evento.html'
)
class VistaVista
{
    
    Vista vista = new Vista();
    String eventoID;
    
    ViewVista (RouteProvider routeProvider) 
    {
        var id = routeProvider.parameters['vistaID'];
        eventoID = routeProvider.parameters['eventoID'];
        
        if (id == null)
        {
            //Crear nuevo evento
            newFromCollection ('vista').then (doIfSuccess ((IdResp res)
            {
                vista.id = res.id;
            }));
        }
        else
        {
            //Cargar vista
            getFromCollection (VistaResp, 'vista', id).then (doIfSuccess ((VistaResp resp)
            {
                vista = resp.vista;
            }));
        }
    }
    
    save ()
    {
        saveInCollection ('vista', vista).then (doIfSuccess());
    }

    
    
    void NuevaVista ()
    {
       
    }
    
}

