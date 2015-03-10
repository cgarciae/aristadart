part of aristadart.server;

@app.Group('/user')
@Catch()
@Encode()
class UserServives extends AristaService<User>
{
    UserServives () : super (Col.user);
    
    @app.DefaultRoute (methods: const [app.POST])
    Future<User> NewOrLogin (@Decode() User user) async
    {   
        try
        {
            return await Find(null, user.email, null, null);
        }
        catch (e){}
        
        if (nullOrEmpty(user.email) ||
            nullOrEmpty(user.nombre) ||
            nullOrEmpty(user.apellido))
            throw new app.ErrorResponse (400, "Error Registrando: nombre: ${user.nombre}," +
                                 "apellido: ${user.apellido}, email: ${user.email}");
        
        ProtectedUser newUser = Cast (ProtectedUser, user)
                        ..id = newId()
                        ..money = 0
                        ..admin = false;
                    
        await insert
        ( 
            newUser
        );
          
        return Cast(User, newUser);
    }
    
    @app.Route ('/:id', methods: const [app.PUT])
    @Private()
    Future<User> Update (@Decode() User delta) async
    {
        //Borrar campos no modificables
        delta.email = null;
        
        //Actualizar
        await UpdateGeneric(userId, delta);
              
        return Get ();
    }
    
    
    @app.Route ('/:id', methods: const [app.GET])
    @Private()
    Future<User> Get () async
    {
        return GetGeneric(userId);
    }
    
    @app.Route ('/:id', methods: const [app.DELETE])
    @Private()
    Future<DbObj> Delete () async
    {
        return DeleteGeneric (userId);
    }
    
    @app.Route ('/:id/eventos', methods: const [app.GET])
    @Private()
    Future<ListEventoResp> Eventos () async
    {
        return new EventoServices().All();
    }
    
    @app.Route ('/:id/isAdmin')
    @Private()
    Future<BoolResp> isAdmin () async
    {
        ProtectedUser user = await db.findOne
        (
            Col.user,
            ProtectedUser,
            where.id(StringToId(userId))
        );
        
        if (user == null)
            throw new app.ErrorResponse (400, "User not found");
        
        return new BoolResp()
            ..value = user.admin;
    }
    
    @app.Route ('/find', methods: const [app.GET])
    @Private (ADMIN)
    Future<User> Find (@app.QueryParam('id') String id,
                       @app.QueryParam('email') String email,
                       @app.QueryParam('nombre') String nombre,
                       @app.QueryParam('apellido') String apellido) async
    {
        var query = {};
        
        if (id != null)
            query['_id'] = StringToId(id);
        
        maybeAdd(query, 'email', email);
        maybeAdd(query, 'nombre', nombre);
        maybeAdd(query, 'apellido', apellido);
        
        User user = await findOne
        (
            where.raw(query)
        );
        
        if (user == null)
            throw new app.ErrorResponse (400, "Usuario no encontrado");
        
        return user;
    }
    
    @app.Route ('/:id/setAsAdmin')
    @Private(ADMIN)
    Future<User> setAdmin (String id, @app.QueryParam() bool admin) async
    {
        var delta = new ProtectedUser ()
            ..admin = admin;
        
        //Actualizar userId para poder actualizar usuario deseado
        userId = id;
        
        return Update(delta);
    }
}



