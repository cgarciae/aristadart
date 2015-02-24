part of aristadart.client;

@Component
(
    selector : "login",
    templateUrl: 'components/login/login.html',
    useShadowDom: false
)
class LoginVista extends ShadowRootAware
{
    
    UserSecure user = new UserSecure();
    Router router;
    
    bool nuevo = false;
    
    LoginVista (this.router)
    {
        
    }
    
    
      onShadowRoot(dom.ShadowRoot root){}
    
    login ()
    {
        print (encodeJson(user));
        print (user.password);
        return jsonRequestDecoded 
        (
            UserAdminResp,
            Method.POST, 
            'user/login',
            user
        )
        .then((UserAdminResp resp){
        
        if (resp.success)
        {
            loginUser(router, resp);
        }
        else
        {
            print (resp.error);
        }
        });
    }
    
    onPressEnter (dom.KeyboardEvent event)
    {
        if (event.keyCode == 13)
        {
            login();
        }
    }
    
    nuevoUsuario()
    {
        nuevo = true;
        router.go ('login.nuevo', {});
    }
    
    

    /// send data to server
    sendDatas(dynamic data) 
    {
        final req = new dom.HttpRequest();
        
        req.onReadyStateChange.listen((dom.Event e) 
        {
            if (req.readyState == dom.HttpRequest.DONE && (req.status == 200 || req.status == 0)) 
            {
                dom.window.alert("upload complete");
            }
        });
        
        req.open ("POST", "http://127.0.0.1:8080/upload");
        req.send (data);
    }
}

