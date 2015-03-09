part of aristadart.client.tests;

runClientUserServicesTest ()
{
    group ("User Services:", ()
    {
        User user;
        ClientUserServices services;
        
        setUp(()
        {
            user = new User()
            ..nombre = "Juan"
            ..apellido = "Perez"
            ..email = "juanperez@gmail.com";
            
            var tempServices = new ClientUserServices(user);
            
            return tempServices.NewOrLogin().then((User resp)
            {
                user = resp;
                userId = resp.id;
                services = new ClientUserServices(user);
            });
        });
        
        tearDown(()
        {
            return services.DeleteGeneric().then((_)
            {
                logout();
            });
        });
        
        test ("Login", ()
        {
            
            return services.NewOrLogin().then((User resp){
            
            expect (resp.success, true);
            expect (resp.nombre, user.nombre);
            expect (resp.apellido, user.apellido);
            expect (resp.email, user.email);
            });
        });
        
        test ("Update", ()
        {
            var delta = new User ()
                ..apellido = "Garcia";
            
            return services.UpdateGeneric(delta).then((User resp){
            
            expect (resp.success, true);
            expect (resp.nombre, user.nombre);
            expect (resp.apellido, delta.apellido);
            expect (resp.email, user.email);
            });
        });
        
        test ("Is Admin", ()
        {
            
            return services.IsAdmin().then((BoolResp resp){
            
            expect (resp.success, true);
            expect (resp.value, false);
            });
        });
    });
}