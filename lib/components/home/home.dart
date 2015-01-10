part of arista_client;



@Component
(
    selector : "home",
    templateUrl: 'components/home/home.html'
)
class Home
{
    
    User user = new UserSecure();
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
        router.go('evento.new', {});
    }
    
    ver (Evento e)
    {
        router.go('evento.edit', {'id': e.id});
    }
    
    eliminar (Evento e, dom.MouseEvent event)
    {
        event.stopImmediatePropagation();
        
        getRequestQueryMap('/private/delete/evento/${e.id}').then((QueryMap res)
        {
            if (res.success)
            {
                eventos.remove(e);
            }
            else
            {
                dom.window.alert("Failed to delete event");
            }
        });
    }
}

