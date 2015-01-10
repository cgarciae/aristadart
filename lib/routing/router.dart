part of arista_client;

void recipeBookRouteInitializer(Router router, RouteViewFactory views) 
{
  views.configure({
    'login': ngRoute(
        path: '/login',
        viewHtml: r'<login-comp></login-comp>',
        defaultRoute: true,
        enter: (_)
        {
            getRequestQueryMap("/user/loggedin")
            .then((QueryMap map) 
            {
                if (map.success)
                {
                    router.go('home', {});
                }
            });
        }),
        
    'home': ngRoute(
            path: '/home',
            viewHtml: r'<home></home>'),
            
    'evento': ngRoute(
            path: '/evento',
            mount: 
            {
                'new' : ngRoute(
                        path: '/new',
                        viewHtml: r'<evento></evento>',
                        enter: (RouteEnterEvent e)
                        {
                            
                        }),
                        
                'edit' : ngRoute (
                        path: '/:id',
                        viewHtml: r'<evento></evento>',
                        preEnter: (RoutePreEnterEvent e)
                        {   
                            var id = e.parameters['id'];
                            
                            if (id == null)
                                router.go('home', {});
                            
                        },
                        enter: (RouteEnterEvent e)
                        {
                            
                        }),
                        
                                       
                        
                        
                'default_view' : ngRoute(
                        defaultRoute: true,
                        enter: (RouteEnterEvent e) =>
                            router.go('home', {}, replace: true))
            })
  });
}