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
    ClientObjetoUnityServices objServices;
    
    bool cambios = false;
     
    VistaConstruccionRA (RouteProvider routeProvider, this.router)
    {
        vista.id = routeProvider.parameters['vistaID'];
        //eventoId = routeProvider.parameters['eventoID'];
        
        vistaServices = new ClientVistaServices(vista);
        
        vistaServices.Get().then((_vista){
        
        print (vista.runtimeType);
        
        vista = _vista;
        
        //Si no existe objeto unity
        return new Future ((){
        objServices = new ClientObjetoUnityServices(vista.objetoUnity);
        
        if (vista.objetoUnity == null || vista.objetoUnity.id == null)
        {
            
            return objServices.All(public: true).then((list){
                
            objetosUsuario = list;
            });
        }
        else
        {
            print ("aca");
            return objServices.GetGeneric().then((_obj){
               
            vista.objetoUnity = _obj;
            });
        }
        })
        .then((_){//Continuar aca
            
        
        });
        }).catchError(printReqError, test: ifProgEvent);
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
    
    saveNombreObjetoUnity ()
    {
        if (cambios)
        {
            cambios = false;
            
            var delta = new ObjetoUnity()
                ..nombre = vista.objetoUnity.nombre;
            
            objServices.UpdateGeneric(delta)
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
}