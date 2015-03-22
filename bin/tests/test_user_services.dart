part of aristadart.tests;

class _EventServicesMock extends Mock implements UserServices {}
class _MongoDbMock extends Mock implements MongoDb {}

userServicesTests ()
{
    group("User Tests", ()
    { 
        setUp(() async 
        {
            
            var eventServices = new _EventServicesMock()
                ..when(callsTo('All')).thenReturn([new Evento()]);
            
            var con = "mongodb://${partialDBHost}/testUserServices";
            var dbManager = new MongoDbManager(con, poolSize: 3);
            
            MongoDb db = await dbManager.getConnection();
            await db.collection(Col.user).drop();
            await db.innerConn.close();
                
            app.addPlugin (getMapperPlugin(dbManager));
            app.addPlugin (AuthenticationPlugin);
            app.addPlugin (ErrorCatchPlugin);
            
            
            app.addModule(new Module()
                       ..bind(EventoServices,  toValue: eventServices)
                       ..bind(User));
          
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
            
            var dbMock = new _MongoDbMock()
                ..when(callsTo('insert')).thenReturn(new Future(() => {}));
            
            req.attributes['dbConn'] = dbMock;
        
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