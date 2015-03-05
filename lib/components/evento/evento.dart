part of aristadart.client;  



@Component
(
    selector : "evento",
    templateUrl: 'components/evento/evento.html',
    useShadowDom: false
)
class EventoVista
{
    bool cambio = false;
    Evento evento = new Evento();
       
    String targetImageUrl = "";
    
    Router router;
    
    //Variables dummy
    List<Vista> vistasUsuario = [];
    bool cargarVistasUsuario = false;

    
    EventoVista (RouteProvider routeProvider, this.router) 
    {
        var eventoID = routeProvider.parameters['eventoID'];

        //Cargar evento
        requestDecoded
        (
            Evento,
            Method.GET,
            'evento/$eventoID',
            userId: userId
        )
        .then((Evento _evento){
        if(_evento.failed)
            return print(_evento.error);            
        
        evento = _evento;
        
        //Cargar vistas
        requestDecoded
        (
            ListVistaResp,
            Method.GET,
            '${evento.href}/vistas',
            userId: userId
        )
        .then((ListVistaResp listVistaResp){
              
        if(listVistaResp.failed)
            return print(listVistaResp.error);
          
        evento.vistas =  listVistaResp.vistas;    
        });
        });
    }
    
    saveDescripcion ()
    {
        if(!cambio)
          return;
        jsonRequestDecoded
        (
            Evento,
            Method.PUT,
            evento.href,
            new Evento()
                ..descripcion = evento.descripcion,
            userId: userId
        )
        .then((Evento evento){
        if(evento.failed)
            return print(evento.error);
        cambio = false;
        //alert.addAlert({'type': 'success','msg': 'La descripción ha sido guardada exitosamente'});
        });
    }
    
    saveNombre ()
    {
        jsonRequestDecoded
        (
            Evento,
            Method.PUT,
            evento.href,
            new Evento()
                ..nombre = evento.nombre,
            userId: userId
        )
        .then((Evento evento){
        if(evento.failed)
            return print(evento.error);
        //alert.addAlert({'type': 'success','msg': 'El nombre ha sido guardada exitosamente'});         
        });
  
    }
    
      
    save ()
    {
        saveInCollection('evento', evento)
        .then(doIfSuccess((Resp resp)
        {
            print("Se guardo con exito");            
            if(resp.failed){
                return print(resp.error);
            }  
        }));       
        
    }
    
    /*
    void closeAlert(Map alert) {
        alerts.remove(alert);
    }

     */
    
    nuevaVista ()
    {
        
        requestDecoded
        (
            Vista,
            Method.POST,
            'vista',
            params: {"eventoID" : evento.id}, 
            userId: userId
        )
        .then((Vista _vista){
        if(_vista.failed)
            return print(_vista.error);
        
        evento.vistas.add(_vista);
        
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
    
    
    iniciarCargaVistasUsuario()
    {
        cargarVistasUsuario = true;
        
        requestDecoded
        (
            ListVistaResp,
            Method.GET,
            'vista/all',
            userId: userId
        )
        .then((ListVistaResp resp){
            
        if (resp.failed)
            return print (resp.error);
            
        vistasUsuario = resp.vistas;
        });
    }
    
    seleccionarVistaEnModal (Vista vista)
    {
        requestDecoded
        (
            Evento,
            Method.POST,
            'evento/${evento.id}/addVista/${vista.id}',
            userId: userId
        )
        .then((Evento _evento){
            
        if (_evento.failed)
            return print (_evento.error);
            
        evento.vistas.add(vista);
        cargarVistasUsuario = false;
        });
    }
}


