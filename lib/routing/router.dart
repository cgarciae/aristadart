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
            path: 'evento/:eventoID',
            preEnter: (RoutePreEnterEvent e)
            {   
                var id = e.parameters['eventoID'];
                
                if (id == null)
                    router.go('home', {});
                
            },
            enter: authenticate ('view/evento_view.html'),

            mount :
            {
                'view' : ngRoute 
                (
                    path: 'view/:vistaID',
                    preEnter: (RoutePreEnterEvent e)
                    {   
                        var eventoID = e.parameters['eventoID'];
                        var viewID = e.parameters['vistaID'];
                        
                        if (viewID == null || eventoID == null)
                            router.go('home', {});
                    },
                    enter: authenticate ('view/view_view.html')
                )
            }
        )
        
  });
}



bool get loggedIn => storage['id'] != null;