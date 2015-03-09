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
    ClientEventoServices eventoServices;

    
    EventoVista (RouteProvider routeProvider, this.router) 
    {
        var eventoID = routeProvider.parameters['eventoID'];
        
        var eventoTemp = new Evento()
            ..id = eventoID;
        
        new ClientEventoServices(eventoTemp).GetGeneric().then((_evento){
            
        if (_evento.failed)
            return print (_evento.error);
        
        evento = _evento;
        eventoServices = new ClientEventoServices(evento);
        
        //Buscar vistas
        return eventoServices.Vistas().then((vistasResp){
            
        if (vistasResp.failed)
            return print (vistasResp.error);
        
        evento.vistas = vistasResp.vistas;
        });
        });
    }
    
    saveDescripcion ()
    {
        if(!cambio)
          return;
        
        var delta = new Evento()
            ..descripcion = evento.descripcion;
        
        eventoServices.UpdateGeneric (delta).then((Evento evento){
            
        if(evento.failed)
            return print(evento.error);
        
        cambio = false;
        });
    }
    
    saveNombre ()
    {
        if(!cambio)
          return;
        
        var delta = new Evento()
            ..nombre = evento.nombre;
        
        eventoServices.UpdateGeneric (delta).then((Evento evento){
            
        if(evento.failed)
            return print(evento.error);
        
        cambio = false;
        });
    }
    
      
    

    
    nuevaVista ()
    {
        
        new ClientVistaServices().NewGeneric (queryParams: {"eventoID" : evento.id})
        .then((Vista _vista){
        
        if(_vista.failed)
            return print(_vista.error);
        
        evento.vistas.add(_vista);
        
        });    
       
    }
    
    
    
    eliminar (Vista v, dom.MouseEvent event)
    {
        event.stopImmediatePropagation();
        
        requestDecoded
        (
            Evento,
            Method.POST,
            'evento/${evento.id}/removeVista/${v.id}',
            userId: userId
        )
        .then((Evento _evento){
            
        if (_evento.failed)
            return print (_evento.error);
        
        evento.vistas.remove(v);
        });
        
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
        dom.FormElement form = getFormElement(event);
        
        if (evento.cloudTarget != null)
        {
            //Actualizar cloudTarget
            formRequestDecoded
            (
                CloudTarget,
                Method.PUT,
                '${evento.cloudTarget.href}/updateFromImage',
                form,
                userId: userId
            )
            .then((CloudTarget _evento){
                
            if (_evento.failed)
                return print (_evento.error);
            
            
            });
        }
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
        if(evento.vistas.any((Vista v) => v.id == vista.id)){
            cargarVistasUsuario = false;
            return print ("La vista ya esta contenida en el evento");
        }
      
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


