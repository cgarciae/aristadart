part of arista_client;

void recipeBookRouteInitializer(Router router, RouteViewFactory view) 
{
    authenticate (String route, [Function onEnter])
    {
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
    
    view.configure(
    {
        'login': ngRoute(
            path: '/login',
            defaultRoute: true,
            enter : (RouteEnterEvent e)
            {
                if (loggedIn)
                {
                    router.go('home', {});
                }
                else
                {               
                    view ('view/login_view.html') (e);
                }
            }),
        
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