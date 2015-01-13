part of arista_client;

@Component
(
    selector : "evento",
    templateUrl: 'components/evento/evento.html'
)
class EventoVista
{
    
    Evento evento = new Evento ();
    List<Vista> vistas = [];
    
    Router router;
    
    EventoVista (RouteProvider routeProvider, this.router) 
    {
        var eventoID = routeProvider.parameters['eventoID'];
        
        if (eventoID == null)
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
            getRequestDecoded(Evento, "private/get/evento/$eventoID").then((Evento e)
            {
                evento = e;
                
                return cargarVistas(e.id);
            });
        }
    }
    
    cargarVistas (String eventID)
    {
        return getRequestDecoded(VistasResp, "private/get/evento/$eventID/vistas")
        .then(doIfSuccess((VistasResp resp)
        {
            vistas = resp.vistas;
        }));
    }
    
    save ()
    {
        saveInCollection('evento', evento)
        .then(doIfSuccess((Resp resp)
        {
            router.go('home', {});
        }));
    }
    
    nuevaVista ()
    {
        getRequestDecoded (IdResp, 'private/new/vista')
        
        .then (doIfSuccess ((resp) => addVistaId (resp.id)));
    }
    
    Future<Resp> addVistaId  (String vistaID)
    {
        var eventoID = evento.id;
        
        return pushIDtoList ('evento', eventoID, 'viewIds', vistaID)
        
        .then (doIfSuccess ((resp)
        {
            var vista = new Vista()
                ..id = vistaID
                ..icon.texto = "Nueva Vista";
            
            return saveVista (vista);
        }));
    }
    
    saveVista (Vista vista)
    {
        return saveInCollection('vista', vista)
                
        .then (doIfSuccess ((_)
        {
            vistas.add (vista);
            evento.viewIds.add (vista.id);
        }));
    }
    
    
    eliminar (Vista v, dom.MouseEvent event)
    {
        event.stopImmediatePropagation();
        
        deleteFromCollection ('vista', v.id)
        .then(doIfSuccess((Resp resp)
        {
            return removeVista (v);
        }));
    }
    
    Future removeVista (Vista v)
    {
        return pullIDfromList('evento', evento.id, 'viewIds', v.id)
        .then(doIfSuccess ((Resp resp) 
        {
            vistas.remove (v);
            evento.viewIds.remove (v.id);
        }));
    }
    
    ver (Vista v)
    {
        //dom.window.alert("evento.id = ${evento.id}");
        router.go ('vista',
        {
            'eventoID' : evento.id,
            'vistaID' : v.id
        });
    }
}

