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
    
    @app.DefaultRoute (methods: const [app.POST, app.PUT])
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
    
    @app.DefaultRoute (methods: const [app.GET])
    @Private()
    @Encode()
    Future<User> Get () async
    {
        User user = await db.findOne
        (
            Col.user,
            User,
            where.id(StringToId(userId))
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
        try
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
        catch (e, s)
        {
            return new ListEventoResp()
                ..error = "$e $s";
        }
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

@app.Route ('/private/user/isadmin')
@Encode()
isAdmin ()
{
    try
    {   
        return new BoolResp()
            ..value = session['admin'];
    }
    catch (e, stacktrace)
    {
        return new BoolResp()
            ..error = e.toString() + stacktrace.toString();
    }
}


@app.Route ('/private/user/panelinfo')
@Encode()
panelInfo (@app.Attr() MongoDb dbConn) async
{
    var userId = session['id'];
        
    UserAdmin user = await dbConn.findOne (Col.user, UserAdmin, where.id (userId));

    var eventIds = user.eventos.map (StringToId).toList();
    List<Evento> eventos = await dbConn.find (Col.evento, Evento, where.oneFrom ('_id', eventIds));
    
    return new PanelInfo()
            ..user = user
            ..eventos = eventos;
}

@app.Route("/user/logout")
logout() 
{
    session.destroy();
    return {"success": true};
}

@app.Route("/user/loggedin")
@Encode()
isLoggedIn() 
{
    try
    {
        ObjectId id = app.request.session['id'];
        
        if (id != null)
            return new IdResp()
                ..id = id.toHexString();
        
        return new Resp()
            ..error = "User not logged in";
    }
    catch (e, stacktrace)
    {
        return new Resp()
            ..error = e.toString() + stacktrace.toString();
    }
}

@app.Route ('/private/userlist')
@Secure(ADMIN)
@Encode()
listUsers(@app.Attr() MongoDb dbConn) {
  
  return dbConn.find('user', UserAdmin);
  
}

@app.Route ('/setadmin/:userid')
@Secure(ADMIN)
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



