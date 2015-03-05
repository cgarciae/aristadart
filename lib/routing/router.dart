part of aristadart.client;

const String loginRoute = "view/login_view.html";

Future<bool> get serverUserLoggedIn
{
    return new Future.value(loggedIn);
}

Future<bool> get serverUserAdmin
{
    return new Future.value(loggedAdmin);
}

void recipeBookRouteInitializer(Router router, RouteViewFactory view) 
{
    
    authenticate2 (RoutePreEnterEvent event)
    {
        event.allowEnter (
            serverUserLoggedIn.then((bool logged){
            
            print ("Logged $logged");
            if (! logged)
            {
                router.go
                (
                    'login', {},
                    forceReload: true
                );
            }
            
            return logged;
        }));          
    }
    
    authenticateAdmin2 (RoutePreEnterEvent event)
    {
        event.allowEnter (
            serverUserLoggedIn.then((bool logged){
            
            print ("Logged $logged");
            if (! logged)
            {
                router.go
                (
                    'login', {},
                    forceReload: true
                );
                return false;
            }
            
            return serverUserAdmin.then((bool admin){
            
            print ("Auth admin $admin");
            if (! admin)
            {
                router.go
                (
                    'home', {},
                    forceReload: true
                );
                return false;
            }
            
            return true;
            });
        })
        );
    }
    
    ifLoggedIn (String route)
    {
        return (RouteEnterEvent e)
        {
            if (loggedIn)
            {
                view (route) (e);
            }
            else
            {
                router.go
                (
                    'login', {},
                    forceReload: true
                );
            }
        };
    }
    
    ifAdmin (String route)
    {
        return (RouteEnterEvent e)
        {
            if (loggedAdmin)
            {
                view (route) (e);
            }
            else
            {
                router.go
                (
                    'home', {},
                    forceReload: true
                );
            }
        };
    }
    
    view.configure(
    {
        'login': ngRoute
        (
            path: '/login',
            defaultRoute: true,
            enter : (RouteEnterEvent event)
            {
                print (loggedIn);
                if (loggedIn)
                {
                    router.go('home', {}, forceReload: true);
                }
                else
                {
                    view (loginRoute) (event);
                }       
            },
            mount: 
            {
                'nuevo' : ngRoute
                (
                    path: '/nuevo',
                    enter: view ('view/nuevo_usuario_view.html')
                )
            }
        ),
        
        'home': ngRoute
        (
            path: '/home',
            enter: ifLoggedIn ('view/home_view.html')
        ),
                
        'evento': ngRoute 
        (
            path: '/evento/:eventoID',
            enter: (RouteEnterEvent event)
            {   
                var id = event.parameters['eventoID'];
                
                if (id == null)
                {
                    router.go('home', {}, forceReload: true);
                    return;
                }
                
                ifLoggedIn ('view/evento_view.html') (event);
            }
        ),
        
        'vista' : ngRoute
        (
            path: '/vista/:eventoID/:vistaID',
            enter: (RouteEnterEvent event)
            {   
                
                var eventoID = event.parameters['eventoID'];
                var viewID = event.parameters['vistaID'];
                
                if (viewID == null || eventoID == null)
                {
                    dom.window.alert("eventoID $eventoID, viewID $viewID");
                    router.go('home', {}, forceReload: true);
                    return;
                }
                
                ifLoggedIn ('view/vista_view.html')(event);
            }
        ),
        
        'admin' : ngRoute
        (
            path: '/admin',
            enter: ifAdmin ('view/admin_view.html')
        ),
        
        'adminModel' : ngRoute
        (
            path: '/admin/model',
            enter: ifAdmin('view/model_view.html')
        ),
        
        'adminTarget' : ngRoute
        (
            path: '/admin/target',
            enter: ifAdmin('view/target_view.html')
        ),
        
        'A' : ngRoute 
        (
            path : '/A/:parA',
            enter: (RouteEnterEvent e)
            {
                e.parameters.keys.forEach(print);
            },
            mount: 
            {
                'B' : ngRoute
                (
                    path: '/B/:parB',
                    enter: (RouteEnterEvent e)
                    {
                        
                    }
                )
            }
        
        ),
        
        'B' : ngRoute
        (
            path: '/A/:A/B/:B',
            enter: (RouteEnterEvent e)
            {
                
                
            }
        )
        
  });
} 


checkLogin ()
{
    return requestDecoded
    (
         IdResp,
         Method.GET,
         "user/loggedin"
     )
     .then((IdResp resp){
    
    if (resp.success)
        storage['id'] = resp.id;
    else
        storage.remove('id');
    
    });
}

checkAdmin ()
{
    return requestDecoded
    (
         IdResp,
         Method.GET,
         "private/user/isadmin"
     )
     .then((IdResp resp){
    
    if (resp.success)
        storage['admin'] = true.toString();
    else
        storage.remove('admin');
    });
}

