part of arista_client;

@Component
(
    selector : "login",
    templateUrl: 'components/login/login.html',
    useShadowDom: false
)
class Login
{
    
    UserSecure user = new UserSecure();
    Router router;
    
    bool nuevo = false;
    
    Login (this.router)
    {
        
    }
    
    login ()
    {
        jsonRequestDecoded('/user/login', user, IdResp).then(doIfSuccess((IdResp obj) 
        {
            storage['id'] = obj.id;
            router.go('home', {});
        }));
    }
    
    nuevoUsuario()
    {
        nuevo = true;
        router.go ('login.nuevo', {});
    }
    
}

