part of arista_client;

@Component
(
    selector : "evento",
    templateUrl: 'components/evento/evento.html',
    useShadowDom: false
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
            requestDecoded(IdResp, Method.POST, 'private/evento').then((IdResp res)
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
            requestDecoded(Evento, Method.GET, "private/get/evento/$eventoID").then((Evento e)
            {
                evento = e;
                
                return cargarVistas(e.id);
            });
        }
    }
    
    cargarVistas (String eventID)
    {
        return requestDecoded(VistasResp, Method.GET,"private/get/evento/$eventID/vistas")
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
        requestDecoded(IdResp, Method.POST, 'private/vista')
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
    
    String iconoURL (Vista v)
    {
        if ((v.icon.urlTextura != null) && (v.icon.urlTextura != ''))
        {
            var opcion = v.icon.urlTextura.split(r'/').last;
            
            return 'images/webapp/${opcion}.png';
        }
        
        return 'images/webapp/missing_image.png';
    }
    
    upload (dom.MouseEvent event)
    {
        String url = '';
        var method = '';
        if(evento.imagenPreview.urlTextura == null || evento.imagenPreview.urlTextura == ""){
            
            url = 'private/file';
            method = Method.POST;
            print("no existe, new");
        }else{
            
            url = "private/file/${evento.imagenPreview.urlTextura.split('/').last}";
            method = Method.PUT;
            print("actualizo");
        }   

        dom.FormElement form = (event.target as dom.ButtonElement).parent as dom.FormElement;
                    
        requestDecoded(IdResp, method, url).then((IdResp resp)
        {   
            print (resp.success);
            evento.imagenPreview.urlTextura = 'public/file/${resp.id}';
            return saveInCollection('evento', evento);
        }).then((Resp resp)
        {
            if(resp.success)
                dom.window.location.reload(); 
        });
    }
}

