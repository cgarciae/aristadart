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
        
        evento = _evento;
        eventoServices = new ClientEventoServices(evento);
        
        //Buscar vistas
        return eventoServices.Vistas().then((_vistas){
        
        evento.vistas = _vistas;
        
        evento.vistas.forEach((v) => print (encode(v)));
        
        //Si existe un cloud target
        return new Future((){
        if (evento.cloudTarget != null)
        {
            //Buscarlo para asignarlo
            return new ClientCloudTargetServices(evento.cloudTarget).GetGeneric().then((target){
            
            evento.cloudTarget = target;
            });
        }            
        }).then((_){
            
        });
        });
        }).catchError(printReqError, test: ifProgEvent);
    }
    
    saveDescripcion ()
    {
        if(!cambio)
          return;
        
        var delta = new Evento()
            ..descripcion = evento.descripcion;
        
        eventoServices.UpdateGeneric (delta).then((Evento evento){
        
        cambio = false;
        })
        .catchError(printReqError, test: ifProgEvent);
    }
    
    saveNombre ()
    {
        if(!cambio)
          return;
        
        var delta = new Evento()
            ..nombre = evento.nombre;
        
        eventoServices.UpdateGeneric (delta).then((Evento evento){
        
        cambio = false;
        })
        .catchError(printReqError, test: ifProgEvent);
    }
    
      
    

    
    nuevaVista ()
    {
        
        new ClientVistaServices().New (eventoId : evento.id).then((Vista _vista){
        
        evento.vistas.add(_vista);
        
        }).catchError(printReqError, test: ifProgEvent);    
        
    }
    
    
    
    eliminar (Vista v, dom.MouseEvent event)
    {
        event.stopImmediatePropagation();
        
        eventoServices.RemoveVista(v.id).then((Evento _evento){
        evento.vistas.remove(v);
        
        }).catchError(printReqError, test: ifProgEvent);
        
    }
    
    
    
    ver (Vista v)
    {
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

            evento.cloudTarget = target;
            dom.window.location.reload(); 
            
            }).catchError(printReqError, test: ifProgEvent);
        }else
        {
            
            new ClientCloudTargetServices().NewFromImage(form)
            .then((CloudTarget target){
                
            var delta = new Evento()
                ..cloudTarget = (new CloudTarget()
                  ..id = target.id);
            
            eventoServices.UpdateGeneric(delta).then((_){
            
            evento.cloudTarget = target; 
            });                             
            }).catchError(printReqError, test: ifProgEvent);
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
            
            dom.window.location.reload();
            
            }).catchError(printReqError, test: ifProgEvent);
        }else
        {
            new ClientFileServices().NewOrUpdate(form)
            .then((FileDb file){

            var delta = new Evento()
                ..imagenPreview = (new FileDb()
                  ..id = file.id);
            
            eventoServices.UpdateGeneric(delta).then((resp){
            evento.imagenPreview = file;
            
            });      
            }).catchError(printReqError, test: ifProgEvent);
        }
    }
    
    iniciarCargaVistasUsuario()
    {
        
        new ClientVistaServices().AllGeneric(ListVistaResp)
        .then((ListVistaResp resp){
        
        print (resp.vistas.length);
            
        vistasUsuario = resp.vistas;
        
        }).catchError(printReqError, test: ifProgEvent);
    }
    
    seleccionarVistaEnModal (Vista vista)
    {
        if(evento.vistas.any((Vista v) => v.id == vista.id)){
            return print ("La vista ya esta contenida en el evento");
        }
      
        eventoServices.AddVista(vista.id)
        .then((Evento _evento){   
        
        evento.vistas.add(vista);
       
        }).catchError(printReqError, test: ifProgEvent);
    }
    
    closeModalVistas ()
    {
      var myModalObj = dom.querySelector("#myModal");
      myModalObj.classes.add("close-reveal-modal");
    }
}


