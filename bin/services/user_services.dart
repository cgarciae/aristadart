part of aristadart.server;



//A public service. Anyone can create a new user
@app.Route("/user", methods: const[app.POST])
@Encode()
postUser(@app.Attr() MongoDb dbConn, @Decode() UserComplete user) async
{   
    print (encode(user));
    
    UserComplete foundUser = await dbConn.findOne 
    (
        Col.user,
        UserComplete,
        where
            .eq("email", user.email)
    );
    
    if (foundUser != null)
    {
        return new Resp()
            ..error = "User Exists";
    }    

    var plainPassword = user.password;
    
    user.id = new ObjectId().toHexString();
    user.password = encryptPassword (user.password);
    user.admin = false;
    user.money = 0;
          
    await dbConn.insert(Col.user, user);

    return login 
    (   
        dbConn, 
        new UserSecure()
            ..email = user.email
            ..password = plainPassword
    );
}

//A public service. Anyone can create a new user
@app.Route("/user/:id", methods: const[app.GET])
@Encode()
getUser(@app.Attr() MongoDb dbConn, String id) async
{
    User user = await dbConn.findOne
    (
        Col.user,
        User,
        where
            .id(StringToId(id))
    );
    
    if (user == null)
        return new Resp()
            ..error = "User not found";
    
        
    return new UserResp()
        ..user = user;
}

@app.Route("/user/login", methods: const[app.POST])
@Encode()
login(@app.Attr() MongoDb dbConn, @Decode() UserSecure user) async
{   
    
    print (user.email);
    print (user.password);
    
    if (user.email == null || user.password == null)
    {
        print ("aca");
        return new IdResp()
            ..error = "WRONG_USER_OR_PASSWORD2";
    }
    
    user.password = encryptPassword(user.password);
    
    print (user.password);
    
    UserAdmin foundUser = await dbConn.findOne 
    (
        Col.user,
        UserAdmin,
        where
            .eq("email", user.email)
            .eq("password", user.password)
    );
    
    //User doesnt exist
    if (foundUser == null)
    {
        return new IdResp()
            ..error = "WRONG USERNAME OR PASSWORD";
    }
    
    
    session["id"] = StringToId(foundUser.id);
    session["admin"] = foundUser.admin;
    
    Set roles = new Set();
    
    if (foundUser.admin)
    {
        roles.add(ADMIN);
    }
    
    session["roles"] = roles;
    
    return new UserAdminResp()
        ..user = (new UserAdmin()
            ..id = foundUser.id
            ..admin = foundUser.admin
            ..email = foundUser.email
            ..nombre = foundUser.nombre
            ..apellido = foundUser.apellido);
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



