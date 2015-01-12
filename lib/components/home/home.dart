part of arista_client;



@Component
(
    selector : "home",
    templateUrl: 'components/home/home.html'
)
class Home
{
    
    User user = new User();
    List<Evento> eventos = [];
    
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
        var userID = storage['id'];
        return getRequestDecoded(Resp, '/private/push/user/$userID/eventos/$eventID')
        
        .then (doIfSuccess ((resp)
        {
            var evento = new Evento()
                ..id = eventID
                ..nombre = 'Nuevo Evento'
                ..descripcion = 'Descripcion';
            
            return saveEvento (evento);
        }));
    }
    
    saveEvento (Evento evento)
    {
        return saveInCollection('evento', evento)
                
        .then (doIfSuccess ((_) => eventos.add(evento)));
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
}

