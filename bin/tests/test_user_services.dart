part of aristadart.tests;

userServicesTests ()
{
    group("User Tests", ()
    { 
        setUp(() 
        {
            var dbManager = new MongoDbManager("mongodb://${partialDBHost}/test", poolSize: 3);
              
            app.addPlugin(getMapperPlugin(dbManager));
            app.addPlugin(AuthenticationPlugin);
            app.addPlugin(ErrorCatchPlugin);
          
            app.setUp([#aristadart.server]);
        });

        //remove all loaded handlers
        tearDown(() => app.tearDown());
    
        test("Login", () async
        {
            String nombre = "Juan";
            String apellido = "Perez";
            String email = "juanperez@gmail.com";
          
            User createUser = new User ()
                ..nombre = nombre
                ..apellido = apellido
                ..email = email;
          
            //create a mock request
            MockRequest req = new MockRequest
            (
                '/user', method: app.POST, bodyType: app.JSON,
                body : encode (createUser)
            );
        
            //dispatch the request
            var resp = await app.dispatch(req);
        
            User user = decodeJson (resp.mockContent, User);
        
            expect(user.id != null, true);
            expect(user.nombre, nombre);
            expect(user.apellido, apellido);
        });
  
        test("2", () async
        {
            print (2);
        
            String nombre = "Juan";
            String apellido = "Perez";
            String email = "juanperez@gmail.com";
        
            User createUser = new User ()
                ..nombre = nombre
                ..apellido = apellido
                ..email = email;
        
            //create a mock request
            MockRequest req = new MockRequest
            (
                '/user', method: app.POST, bodyType: app.JSON,
                body : encode (createUser)
            );
      
            //dispatch the request
            var resp = await app.dispatch(req);
      
            User user = decodeJson (resp.mockContent, User);

        });
    });
}