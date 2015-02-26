part of aristadart.client;  



@Component
(
    selector : "evento",
    templateUrl: 'components/evento/evento.html',
    useShadowDom: false
)
class EventoVista
{
    EventoExportable evento = new EventoExportable();
    
    List<VistaExportable> get vistas => evento.vistas;
    set vistas (List<VistaExportable> vs) => evento.vistas = vs;
    
    String targetImageUrl = "";
    
    Router router;
    
    EventoVista (RouteProvider routeProvider, this.router) 
    {
        var eventoID = routeProvider.parameters['eventoID'];

        //Cargar evento
        requestDecoded(EventoExportable, Method.GET, "private/evento/$eventoID").then((EventoExportable e)
        {
            evento = e;
            
            setTargetImage();
            
            return cargarVistas(e.id);
        });
    }
    
    cargarVistas (String eventID)
    {
        return requestDecoded(
            VistasExportableResp, 
            Method.GET,
            "private/evento/$eventID/vistas"
        )
        .then(doIfSuccess((VistasExportableResp resp)
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
        print (Method.POST);
        /*
        newFromCollection ('vista').then (doIfSuccess ((resp) 
            => addVistaId (resp.id))
        );
         */
        newFromCollection ('vista').then((IdResp idResp){
        
        if(idResp.failed){
            return print(idResp.error);
        }
        
        //addVista
        var eventoID = evento.id;
        return pushIDtoList('evento', eventoID, 'viewIds', idResp.id).then((Resp resp){
        
        if(resp.failed)
        {
            return print(resp.error);
        }
        
        var vista = new Vista()
            ..id = idResp.id
            ..icon.texto = "Nueva Vista";
        
        //saveVista
        return saveInCollection('vista', vista).then((Resp resp2){
        
        if(resp2.failed)
        {
            return print (resp2.error);
        } 
                      
        vistas.add (vista);
        evento.viewIds.add (vista.id);
        
        });
        });
        });
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
        var opcion = v.icon.urlTextura.split(r'/').last; 
        if ((opcion == null) || (opcion == ''))
           opcion = 'missing_image';
        return 'images/webapp/${opcion}.png';
        
    }
    
    upload (dom.MouseEvent event)
    {
        String url = '';
        var method = '';
        if(evento.imagenPreview.path == null || evento.imagenPreview.path == ""){
            
            url = 'private/file';
            method = Method.POST;
            print("no existe, new");
        }else{
            
            url = "private/file/${evento.imagenPreview.path.split('/').last}";
            method = Method.PUT;
            print("actualizo");
        }   

        dom.FormElement form = (event.target as dom.ButtonElement).parent as dom.FormElement;
        dom.FormData data = new dom.FormData (form);
                    
        requestDecoded(IdResp, method, url, data: data).then((IdResp resp)
        {   
            print (resp.success);
            evento.imagenPreview.path = 'public/file/${resp.id}';
            return saveInCollection('evento', evento);
        }).then((Resp resp)
        {
            if(resp.success)
                dom.window.location.reload(); 
        });
    }
    
    uploadTarget (dom.MouseEvent event)
    {
        String url = 'private/vuforiaimage/${evento.id}';
        var method = '';
        
        if (targetImageUrl == null || targetImageUrl == "")
        {
            method = Method.POST;
            print("new");
        }
        else
        {
            method = Method.PUT;
            print("actualizar");
        }   

        dom.FormElement form = (event.target as dom.ButtonElement).parent as dom.FormElement;
                    
        formRequestDecoded (RecoTargetResp, method, url, form).then (doIfSuccess ((RecoTargetResp resp)
        {   
            targetImageUrl = 'private/file/${resp.recoTarget.imageId}';
        }))
        .then ((_)
        {
            dom.window.location.reload(); 
        });
    }
    
    setTargetImage ()
    {
        if (evento.cloudRecoTargetId != null)
        {
            requestDecoded
            (
                RecoTargetResp, 
                Method.GET, 
                'public/cloudreco/${evento.cloudRecoTargetId}'
            )
            .then (doIfSuccess ((RecoTargetResp resp)
            {
                targetImageUrl = 'public/file/${resp.recoTarget.imageId}';
            }));
        }
    }
}


