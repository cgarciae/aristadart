part of arista_client;

void recipeBookRouteInitializer(Router router, RouteViewFactory view) 
{
    //TODO: Usar con pre-enter que acepta utilizar Future<bool> y utilizar async
    
    authenticate (String route, [Function onEnter]) 
    {
        checkLogin();
        
        return (RouteEnterEvent e)
        {
            if (! loggedIn)
            {
                 router.go('login', {});
            }
            else
            {
                if (onEnter != null)
                    onEnter ();
                
                view (route) (e);
            }
        };
    }
    
    authenticateAdmin (String route, [Function onEnter])
    {
        return (RouteEnterEvent e) async
        {
            if (! await loggedIn)
            {
                router.go('login', {});
            }
            else if (! await loggedAdmin) 
            {
                router.go('home', {});
            }
            else{
                if (onEnter != null)
                    onEnter ();
                
                view (route) (e);                        
            }
        };
    }
    
    view.configure(
    {
        'login': ngRoute
        (
            path: '/login',
            defaultRoute: true,
            enter : (RouteEnterEvent e)
            {
                checkLogin();
                
                if (loggedIn)
                {
                    print ("go home");
                    router.go('home', {});
                }
                else
                {     
                    print ("loggin");
                    view ('view/login_view.html') (e);
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
            enter: authenticate ('view/home_view.html')                  
        ),
                
        'evento': ngRoute 
        (
            path: '/evento/:eventoID',
            preEnter: (RoutePreEnterEvent e)
            {   
                var id = e.parameters['eventoID'];
                
                if (id == null)
                    router.go('home', {});
                
            },
            enter: authenticate ('view/evento_view.html')
        ),
        
        'vista' : ngRoute
        (
            path: '/vista/:eventoID/:vistaID',
            preEnter: (RoutePreEnterEvent e)
            {   
                e.parameters.keys.forEach(print);
                
                var eventoID = e.parameters['eventoID'];
                var viewID = e.parameters['vistaID'];
                
                if (viewID == null || eventoID == null)
                {
                    dom.window.alert("eventoID $eventoID, viewID $viewID");
                    router.go('home', {});
                }
            },
            enter: authenticate ('view/vista_view.html')
        ),
        
        'admin' : ngRoute
        (
            path: '/admin',
            enter: authenticateAdmin('view/admin.html') 
        ),
        
        'A' : ngRoute 
        (
            path : '/A/:parA',
            enter: (RouteEnterEvent e)
            {
                print ('ENTERED A');
                e.parameters.keys.forEach(print);
            },
            mount: 
            {
                'B' : ngRoute
                (
                    path: '/B/:parB',
                    enter: (RouteEnterEvent e)
                    {
                        print ('ENTERED B');
                        e.parameters.keys.forEach(print);
                    }
                )
            }
        
        ),
        
        'B' : ngRoute
        (
            path: '/A/:A/B/:B',
            enter: (RouteEnterEvent e)
            {
                print ('BBB');
                e.parameters.keys.forEach(print);
            }
        )
        
  });
}

bool get loggedIn => storage['id'] != null;
set loggedIn (bool value)
{
    if (! value)
        storage['id'] = null;
}

checkLogin () async
{
    IdResp resp = await requestDecoded
    (
         IdResp,
         Method.GET,
         "user/loggedin"
     );
    
    if (resp.success)
        storage['id'] = resp.id;
    else
        storage.remove('id');
}
//var userCollection = conn.collection("user");
Future<bool> get loggedAdmin async{
    BoolResp resp = await requestDecoded(
             BoolResp,
             Method.GET,
             '/private/user/isadmin');
    
    if( resp.success)
        return resp.value;
    else
        return false;
}

