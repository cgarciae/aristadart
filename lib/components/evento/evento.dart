part of arista_client;

@Component
(
    selector : "evento",
    templateUrl: 'components/evento/evento.html'
)
class EventoVista
{
    
    Evento evento = new Evento ();
    
    EventoVista (RouteProvider routeProvider) 
    {
        var id = routeProvider.parameters['id'];
        
        if (id == null)
        {
            //Crear nuevo evento
            getRequestQueryMap('private/new/evento').then((QueryMap res)
            {
                if (res.success)
                {
                    evento.id = res.id;
                }
            });
            
        }
        else
        {
            //Cargar evento
            getRequestDecoded(Evento, "private/get/evento/$id").then((Evento e)
            {
                evento = e;
            });
        }
    }
    
    save ()
    {
        jsonRequestQueryMap('private/save/evento', evento)
        .then((QueryMap map)
        {
            if (map.success == null || ! map.success)
            {
                dom.window.alert('Save Failed');
            }
        });
    }
    
    void NuevaVista ()
    {
       
    }
    
}

