part of arista_client;



@Component
(
    selector : "home",
    templateUrl: 'components/home/home.html',
    useShadowDom: false
)
class Home
{
    
    User user = new User();
    List<Evento> eventos = [];
    String url = '';
    
    Router router;
    
    Home (this.router)
    {
        getUser();
    }
    
    getUser ()
    {
        getRequestDecoded (PanelInfo,'/private/user/panelinfo')
        .then ((PanelInfo info)
        {
            user = info.user;
            eventos = info.eventos;
            
        })
        .catchError((e)
        {
            print ('Error type ${e.runtimeType}');
            router.go('login', {});
        },
        test: (e) => e is dom.ProgressEvent);
        
    }
    
    nuevoEvento ()
    {
        getRequestDecoded (IdResp, 'private/new/evento')
        
        .then (doIfSuccess ((resp) => addEventId (resp.id)));
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
        router.go('evento', {'eventoID': e.id});
    }
    
    eliminar (Evento e, dom.MouseEvent event)
    {
        event.stopImmediatePropagation();
        
        deleteFromCollection ('evento', e.id)
        .then(doIfSuccess((Resp resp)
        {
            return removeEvento (e);
        }));
    }
    
    Future removeEvento (Evento e)
    {
        return pullIDfromList('user', storage['id'], 'eventos', e.id)
        .then(doIfSuccess ((Resp resp) => eventos.remove(e)));
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

