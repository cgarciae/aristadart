part of aristadart.client;

@Component
(
    selector : "login",
    templateUrl: 'components/login/login.html',
    useShadowDom: false
)
class LoginVista extends ShadowRootAware
{
    
    User user = new User();
    Router router;
    bool immediate = false;
    
    var id = new auth.ClientId("287932517253-d6fp73ms7d33ith6r561p1g225q5th0h.apps.googleusercontent.com", null);
    var scopes = ["openid", "email"];
    
    LoginVista (this.router)
    {

    }
    
    
      onShadowRoot(dom.ShadowRoot root){}
      
    login2 ()
    {
        return jsonRequestDecoded
        (
            User, 
            Method.POST,
            '/user',
            user
        )
        .then((User dbUser){
            
        if (dbUser.failed)
        {
            print (dbUser.error);
            return null;
        }
        userId = dbUser.id;
        print (encode(dbUser));
        
        return requestDecoded
        (
            BoolResp, Method.GET, '/user/isAdmin'
        )
        .then((BoolResp resp){
            
        loggedAdmin = resp.success && resp.value;
        
        router.go('home', {});
        });
        });
    }
    
    login ()
    {
        getClient().then((auth.AutoRefreshingAuthClient client){
            
        var oauthApi = new oauth.Oauth2Api(client);
        
        print ("aca");
        
        oauthApi.userinfo.get().then((oauth.Userinfoplus info){
                    
        
        User googleUser = new User()
            ..email = info.email
            ..nombre = info.name
            ..apellido = info.familyName;
        
        return jsonRequestDecoded
        (
            User, 
            Method.POST,
            '/user',
            googleUser
        )
        .then((User dbUser){
            
        if (dbUser.failed)
        {
            print (dbUser.error);
            return null;
        }
        userId = dbUser.id;
        print (encode(dbUser));
        
        return requestDecoded
        (
            BoolResp, Method.GET, '/user/isAdmin'
        )
        .then((BoolResp resp){
            
        loggedAdmin = resp.success && resp.value;
        
        router.go('home', {});
        });
        });
        });
        });
    }
    
    Future<auth.AutoRefreshingAuthClient> getClient()
    {
        return auth.createImplicitBrowserFlow(id, scopes)
                            .then((auth.BrowserOAuth2Flow flow) {
                        
        return flow.clientViaUserConsent(immediate: immediate).then((auth.AutoRefreshingAuthClient client){
            
        immediate = false;
        
        return client;
        
        }).catchError((_) {
                
        immediate = true;    
                
        }, test: (error) => error is auth.UserConsentException);
        });
    }
    
    onPressEnter (dom.KeyboardEvent event)
    {
        
    }
    
    nuevoUsuario()
    {
        
    }
    
    
}

