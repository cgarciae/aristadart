part of aristadart.client;

@Injectable()
class MainController 
{
    bool abierto = true;
    String titulo = "";
    
    Router router;
    
    static MainController i;
    
    MainController (this.router)
    {
        i = this;
        
    }
    
    
    
    
    logout ()
    {
        userId = "";
        loggedAdmin = false;
        
        router.go('login', {});
    }
            
    bool get isLoggedIn => loggedIn;

    go2home(){
        router.go('home',{});
    }
    
}