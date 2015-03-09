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
        
        eventoServices.RemoveVista(v.id)
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
    
    uploadTarget (dom.MouseEvent event)
    {
        dom.FormElement form = getFormElement(event);
        
        if (evento.cloudTarget != null)
        {
            //Actualizar cloudTarget
            new ClientCloudTargetServices(evento.cloudTarget).UpdateFromImage(form)
            .then((CloudTarget target){
                
            if (target.failed)
                return print (target.error);
            
            evento.cloudTarget = target;
            
            dom.window.location.reload(); 
            
            });
        }else
        {
            
            new ClientCloudTargetServices().NewFromImage(form)
            .then((CloudTarget target){
                
            if (target.failed)
                return print (target.error);
            
            var delta = new Evento()
                ..cloudTarget = (new CloudTarget()
                  ..id = target.id);
            
            eventoServices.UpdateGeneric(delta).then((_){
            
            evento.cloudTarget = target; 
            });                     
                      
            });
        }
    }
    
    uploadImagePreview (dom.MouseEvent event)
    {
        dom.FormElement form = getFormElement(event);
                
        if (evento.imagenPreview != null)
        {
            //Actualizar cloudTarget
            new ClientFileServices(evento.imagenPreview).UpdateFile(form)
            .then((FileDb file){
                
            if (file.failed)
                return print (file.error);
            
            dom.window.location.reload();
            });
        }else
        {
            new ClientFileServices().NewOrUpdate(form)
            .then((FileDb file){
                
            if (file.failed)
                return print (file.error);
            
            var delta = new Evento()
                ..imagenPreview = (new FileDb()
                  ..id = file.id);
            
            eventoServices.UpdateGeneric(delta).then((resp){
            
            if (resp.failed)
                return print (resp.error);
            
            evento.imagenPreview = file;
            });      
            });
        }
    }
    
    iniciarCargaVistasUsuario()
    {
        
        new ClientVistaServices().AllGeneric(ListVistaResp)
        .then((ListVistaResp resp){
            
        if (resp.failed)
            return print (resp.error);
            
        vistasUsuario = resp.vistas;
        });
    }
    
    seleccionarVistaEnModal (Vista vista)
    {
        if(evento.vistas.any((Vista v) => v.id == vista.id)){
            return print ("La vista ya esta contenida en el evento");
        }
      
        eventoServices.AddVista(vista.id)
        .then((Evento _evento){
            
        if (_evento.failed)
            return print (_evento.error);
        
        evento.vistas.add(vista);
        });
    }
}


