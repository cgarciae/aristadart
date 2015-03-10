part of aristadart.client;


@Component
(
    selector : "home",
    templateUrl: 'components/home/home.html',
    useShadowDom: false
)
class HomeVista
{
    
    User user = new User();
    List<Evento> eventos = [];
    String url = '';
    
    Router router;
    ClientUserServices userServices;
    
    HomeVista (this.router)
    {
        userServices = new ClientUserServices(new User()
                                                ..id = userId);
        
        userServices.GetGeneric().then (doIfSuccess((User _user){
        
        user = _user;
        return userServices.Eventos().then(doIfSuccess((ListEventoResp _eventos){
            
        eventos = _eventos.eventos;
        }));
        })).catchError(printReqError, test: ifProgEvent);
    }
    
    bool get isAdmin => loggedAdmin;
    
   
    
    nuevoEvento ()
    {
        new ClientEventoServices().NewGeneric().then((_evento){
            
        eventos.add(_evento);
        })
        .catchError(printReqError, test: ifProgEvent);
    }
    
    
    ver (Evento e)
    {
        print ("VER EVENTO");
        router.go('evento', {'eventoID': e.id});
    }
    
    eliminar (Evento e, dom.MouseEvent event)
    {
        event.stopImmediatePropagation();
       
        new ClientEventoServices(e).DeleteGeneric().then((resp){
            
        eventos.remove (e);
        })
        .catchError(printReqError, test: ifProgEvent);
    }
    
    go2Admin(){
        router.go('admin', {});
    }
    
//    upload (dom.MouseEvent event)
//    {
//        dom.FormElement form = (event.target as dom.ButtonElement).parent as dom.FormElement;
//        
//        formRequestDecoded('private/new/file', form, IdResp).then((IdResp resp)
//        {
//            print (resp.success);
//            url = 'public/get/file/${resp.id}';
//        });
//    }
}

