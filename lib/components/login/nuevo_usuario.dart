part of aristadart.client;

@Component
(
    selector : "nuevo-usuario",
    templateUrl: 'components/login/nuevo_usuario.html',
    useShadowDom: false
)
class NuevoUsuarioVista
{
    UserComplete user = new UserComplete();
    String password2 = "";
    
    Router router;
    
    NuevoUsuarioVista(this.router);
    
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
            return jsonRequestDecoded
            (
                UserAdminResp,
                Method.POST, 
                'user', 
                user
            )
            .then((UserAdminResp resp){
            
            if (resp.success)
            {
                loginUser(router, resp);
            }
            });
        }
        else
        {
            print('Campos Incompletos');
        }
    }
}