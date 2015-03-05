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
    
    HomeVista (this.router)
    {
        getUser();
    }
    
    bool get isAdmin => loggedAdmin;
    
    getUser ()
    {
        //Get el usuerio
        requestDecoded
        (
            User,
            Method.GET,
            'user',
            userId: userId
        )
        .then((User _user){
        if(_user.success)
            user = _user;
        else
            print(_user.error);
        });
        
        //Get los eventos
        
        requestDecoded
        (
            ListEventoResp,
            Method.GET,
            'evento/all',
            userId: userId
        )
        .then((ListEventoResp resp){
        if(resp.success)
            eventos = resp.eventos;
        else
            print(resp.error);    
          
        });
        
    }
    
    nuevoEvento ()
    {
        requestDecoded
        (
            Evento,
            Method.POST,
            'evento',
            userId: userId
        )
        .then((Evento evento){
        if(evento.success)
            eventos.add(evento);
        else
            print(evento.error);    
          
        });
    }
    
    Future<Resp> addEventId  (String eventID)
    {
        var evento = new Evento()
                ..id = eventID
                ..nombre = 'Nuevo Evento'
                ..descripcion = 'Descripcion';
        
        eventos.add(evento);
            
        return saveInCollection('evento', evento);
    }
    
    
    ver (Evento e)
    {
        print ("VER EVENTO");
        router.go('evento', {'eventoID': e.id});
    }
    
    eliminar (Evento e, dom.MouseEvent event)
    {
        event.stopImmediatePropagation();
       
        requestDecoded
        (
            DbObj,
            Method.DELETE,
            e.href,
            userId: userId
        )
        .then((DbObj dbObj){
        if(dbObj.success)
            eventos.remove(e);
        else
            print(dbObj.error);    
          
        });
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

