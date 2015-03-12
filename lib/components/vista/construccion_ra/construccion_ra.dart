part of aristadart.client;

@Component
(
    selector : "construccion-ra",
    templateUrl: 'components/vista/construccion_ra/construccion_ra.html',
    useShadowDom: false
)
class VistaConstruccionRA
{
    
    ConstruccionRA vista = new ConstruccionRA();
    ClientVistaServices vistaServices;
    Router router;
    List<ObjetoUnity> objetosUsuario = [];
    List<LocalImageTarget> targetsUsuario = [];
    
    ClientObjetoUnityServices objServices;
    ClientLocalTargetServices targetServices;
    
    List<String> _tags = [];
    List<String> get tags => vista.objetoUnity != null && vista.objetoUnity.tags != null ?
                             vista.objetoUnity.tags :
                             _tags;
    
    bool cambios = false;
     
    VistaConstruccionRA (RouteProvider routeProvider, this.router)
    {
        vista.id = routeProvider.parameters['vistaID'];
        //eventoId = routeProvider.parameters['eventoID'];
        
        vistaServices = new ClientVistaServices(vista);
        
        vistaServices.Get().then((_vista){
        
        vista = _vista;
        
        //Si no existe objeto unity
        return new Future ((){
        objServices = new ClientObjetoUnityServices(vista.objetoUnity);
        
        if (vista.objetoUnity == null || vista.objetoUnity.id == null)
        {
            
            return getAllObjets();
        }
        else
        {

            return objServices.GetGeneric().then((_obj){
               
            vista.objetoUnity = _obj;
            });
        }
        })
        .then((_){//Continuar aca
        //Si no existe objeto unity
        return new Future ((){
        targetServices = new ClientLocalTargetServices(vista.localTarget);
      
        if (vista.localTarget == null || vista.localTarget.id == null)
        {
          
            return getAllTargets();
        }
        else
        {
            return targetServices.GetGeneric().then((_obj){
             
            vista.localTarget = _obj;
            });
        }
        });
        });
        }).catchError(printReqError, test: ifProgEvent);
    }
    
    Future getAllObjets()
    {
        return objServices.All(public: true).then((list){
                        
        objetosUsuario = list;
        });
    }
    
    Future getAllTargets()
    {
        return targetServices.All(public: true).then((list){
                      
        targetsUsuario = list;
        });
    }
    
    seleccionarObjeto (ObjetoUnity obj)
    {
        var delta = new ConstruccionRA()
            ..objetoUnity = (new ObjetoUnity()
                ..id = obj.id);
        
        vistaServices.Update(delta).then((_){
        
        vista.objetoUnity = obj;
        objServices = new ClientObjetoUnityServices(obj);
        })
        .catchError(printReqError, test: ifProgEvent);
    }
    
    
    seleccionarTarget (obj)
    {
        var delta = new ConstruccionRA()
            ..localTarget = (new LocalImageTarget()
                ..id = obj.id);
        
        
        vistaServices.Update(delta).then((_){
            
        
        vista.localTarget = obj;
        targetServices = new ClientLocalTargetServices (obj);
        
        })
        .catchError(printReqError, test: ifProgEvent);
    }
    
    saveNombreObjetoUnity ()
    {       
      
        if (cambios)
        {
            if(vista.objetoUnity.public && vista.owner.id != userId){
                return print("El modelo es público");
            }
          
            cambios = false;
            
            var delta = new ObjetoUnity()
                ..nombre = vista.objetoUnity.nombre;
            
            objServices.UpdateGeneric(delta)
            .catchError(printReqError, test: ifProgEvent);
        }
    }
    
    saveNombreLocalImageTarget ()
    {
        if (cambios)
        {
            if(vista.localTarget.public && vista.owner.id != userId){
                return print("El modelo es público");
            }
                      
            cambios = false;
            
            var delta = new LocalImageTarget()
                ..nombre = vista.localTarget.nombre;
            
            targetServices.UpdateGeneric(delta)
            .catchError(printReqError, test: ifProgEvent);
        }
    }
    
    uploadObjetoUnityUserFile (dom.MouseEvent event)
    {
        var form = getFormElement(event);
        
        
        objServices.NewOrUpdateUserFile(form).then((_obj){
           
        vista.objetoUnity = _obj;
        
        });
    }
    
    uploadLocalTargetImageFile (dom.MouseEvent event)
    {
        var form = getFormElement(event);
        
        targetServices.NewOrUpdateUserFile(form).then((_obj){
           
        vista.localTarget = _obj;
        dom.window.location.reload();
        });
    }
    
    
    maybeSave (Function f)
    {
        if (cambios)
        {
            cambios = false;
            return f();    
        }
    }
    
    update (ConstruccionRA delta)
    {
        return maybeSave ((){
            
            return vistaServices.Update(delta)
                .catchError(printReqError, test: ifProgEvent);
        });
    }
    
    saveVistaNombre()
    {
        var delta = new ConstruccionRA()
            ..nombre = vista.nombre;
            
        return update (delta);
    }
    
    saveElementos()
    {
        if (cambios)
        {
            cambios = false;
            
            return uploadElements();
        }
    }
    
    Future uploadElements()
    {
        return new Future ((){//Delay
        //Guardar vista
        var delta = new ConstruccionRA()
            ..elementosInteractivos = vista.elementosInteractivos;
      
        return vistaServices.Update(delta).then((_vista){
            
        });
        })
        .catchError(printReqError, test: ifProgEvent);
    }
    
    agregarElemento ()
    {
        if (vista.elementosInteractivos == null)
            vista.elementosInteractivos = [];
        
        var elemento = new ElementoInteractivo()
            ..titulo = 'titulo'
            ..texto = 'Descripcion';
        
        vista.elementosInteractivos.add(elemento);
        
        return uploadElements();
    }
    
    borrarElemento (ElementoInteractivo elemento)
    {
        vista.elementosInteractivos.remove(elemento);
        
        return uploadElements();
    }
    
    uploadImagenElemento (dom.MouseEvent event, ElementoInteractivo elemento)
    {
        var form = getFormElement(event);
        var update = false;
        new Future((){
        if (elemento.image == null)
        {
            return new ClientFileServices().NewOrUpdate(form).then((_file){
                
            elemento.image = _file;
            });
        }
        else
        {
            return new ClientFileServices(elemento.image).UpdateFile(form).then((_file){
                            
            elemento.image = _file;
            update = true;
            });
        }
        })
        .then((_){
        
        if (update)
        {
            return uploadElements().then((_){
                
            dom.window.location.reload();
            });
        }
        });
        
    }
    
    crearObjetoUnity()
    {
        objServices.NewGeneric().then((_objUnity){
        vista.objetoUnity = _objUnity;
        });
    }
    
    cambiarObjetoUnity()
    {
        vista.objetoUnity.id = null;
        return getAllObjets();
    }
}