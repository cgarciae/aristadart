part of arista_client;

@Component
(
    selector : "login-comp",
    templateUrl: 'components/login/login.html'
)
class Login
{
    
    UserSecure user = new UserSecure();
    
    Login ()
    {
        
    }
    
    login ()
    {
        jsonRequestQueryMap('/user/login', user)
        .then((QueryMap obj) 
        {
            if (obj.success)
            {
                dom.window.localStorage['id'] = obj.id;
                dom.window.location.href = '#/home';
            }
            else
            {
                dom.window.alert(obj.error);
            }
        });
    }
    
    
}

