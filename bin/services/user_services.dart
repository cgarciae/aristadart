part of aristadart.server;

@app.Group('/user')
class UserServives
{
    Future<User> QueryUser (Map query) async
    {
        User user = await db.findOne
        (
            Col.user,
            User,
            where.raw(query)
        );
        
        if (user == null)
            return new User()
                ..error = "Usuario no encontrado";
        
        return user;
    }
    
    @app.DefaultRoute (methods: const [app.POST])
    @Encode()
    Future<User> NewOrLogin (@Decode() ProtectedUser user) async
    {
        try
        {
            User dbUser = await QueryUser({'email' : user.email});
            
            if (dbUser.success)
                return dbUser;
            
            user = user..id = newId()
                    ..money = 0
                    ..admin = false;
            
            await db.insert
            (
                Col.user, 
                user
            );
              
            return Cast (User, user);
        }
        catch (e, s)
        {
            return new User()
                ..error = "$e $s";
        }
    }
    
    @app.DefaultRoute (methods: const [app.PUT])
    @Private()
    @Encode()
    Future<User> Update (@Decode() User delta) async
    {
        try
        {
            await db.update
            (
                Col.user,
                where.id(StringToId(userId)),
                getModifierBuilder(delta)
            );
              
            return Get ();
        }
        catch (e, s)
        {
            return new User()
                ..error = "$e $s";
        }
    }
    
    @app.Route ('/:id', methods: const [app.GET])
    @Private(ADMIN)
    @Encode()
    Future<User> GetUser (String id) async
    {
        return Get (id);
    }
    
    @app.DefaultRoute (methods: const [app.GET])
    @Private()
    @Encode()
    Future<User> Get ([String id]) async
    {
        //Define userId
        var _userId = id == null ? userId : id;
        
        User user = await db.findOne
        (
            Col.user,
            User,
            where.id(StringToId(_userId))
        );
        
        if (user == null)
            return new User ()
                ..error = "Usuario no encontrado";
          
        return user;
    }
    
    @app.Route ('/eventos', methods: const [app.GET])
    @Private()
    @Encode()
    Future<ListEventoResp> Eventos (String id) async
    {
        List<Evento> eventos = await db.find
        (
            Col.evento,
            Evento,
            where.eq("owner._id", StringToId(userId))
        );
        
        return new ListEventoResp()
            ..eventos = eventos;
    }
    
    @app.Route ('/isAdmin')
    @Private()
    @Encode()
    Future<BoolResp> isAdmin () async
    {
        try
        {
            ProtectedUser user = await db.findOne
            (
                Col.user,
                ProtectedUser,
                where.id(StringToId(userId))
            );
            
            if (user == null)
                return new BoolResp ()
                    ..error = "User not found";
            
            return new BoolResp()
                ..value = user.admin;
        }
        catch (e, s)
        {
            return new BoolResp()
                ..error = "$e $s";
        }
    }
}


@app.Route ('/setadmin/:userid')
@Encode()
setAdmin (@app.Attr() MongoDb dbConn, String userid) async
{
    try
    {
        await dbConn.update
        (
            Col.user,
            where.id (StringToId (userid)),
            modify.set('admin', true)
        );
    
        return new Resp();
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..error = e.toString() + stacktrace.toString();
    }
}



