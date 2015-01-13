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
    
    Login ()
    {
        
    }
    
    login ()
    {
        jsonRequestDecoded('/user/login', user, IdResp)
        .then((IdResp obj) 
        {
            if (obj.success)
            {
                storage['id'] = obj.id;
                dom.window.location.href = '#/home';
            }
            else
            {
                dom.window.alert(obj.error);
            }
        });
    }
    
    
}

