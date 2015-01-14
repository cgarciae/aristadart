part of arista_client;

@Component
(
    selector : "nuevo-usuario",
    templateUrl: 'components/login/nuevo_usuario.html'
)
class NuevoUsuario
{
    UserComplete user = new UserComplete();
    String password2 = "";
    
    Router router;
    
    NuevoUsuario(this.router);
    
    String get passwordStatus
    {
        return user.password == '' || password2 == '' ?     '' :
               user.password != password2 ?                 'Las contraseñas no coinciden' : 
                                                            'OK';           
    }
    
    bool get registrable
    {
        return user.nombre != '' && user.apellido != '' && user.email != '' && passwordStatus == 'OK';
    }
    
    registrar()
    {
        if (registrable)
        {
            jsonRequestDecoded('new/user', user, IdResp).then(doIfSuccess((IdResp resp)
            {
                print ('NEW USER');
                return jsonRequestDecoded('/user/login', user, IdResp);
            }))
            .then(doIfSuccess((IdResp obj) 
            {
                print ('LOGIN');
                
                storage['id'] = obj.id;
                router.go('home', {});
            }));
        }
        else
        {
            dom.window.alert('Campos Incompletos');
        }
    }
}