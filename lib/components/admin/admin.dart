part of aristadart.client;

@Component
(
    selector : 'admin',
    templateUrl: 'components/admin/admin.html',
    useShadowDom: false
)
class AdminVista{
    
    Router router;
    AdminVista(this.router){
        
    }
    
    goModel ()
    {
        router.go('adminModel',{});
    }
    
    goTarget ()
    {
        router.go('adminTarget',{});
    }
    
}