part of arista_server;



//A public service. Anyone can create a new user
@app.Route("/user", methods: const[app.POST])
@Encode()
addUser(@app.Attr() MongoDb dbConn, @Decode() UserComplete user) async
{   
    UserComplete foundUser = await dbConn.findOne 
    (
        Col.user,
        UserComplete, 
        {"email": user.email}
    );
    
    if (foundUser != null)
    {
        return new Resp()
            ..success = false
            ..error = "User Exists";
    }    

    user.id = new ObjectId().toHexString();
    user.password = encryptPassword (user.password);
    user.admin = false;
    user.money = 0;
          
    await dbConn.insert(Col.user, user);

    return new IdResp()
        ..success = true
        ..id = user.id;
}

@app.Route("/user/login", methods: const[app.POST])
@Encode()
login(@app.Attr() MongoDb dbConn, @Decode() UserSecure user) async
{   
    
    print (encodeJson(user));
    
    if (user.email == null || user.password == null)
    {
        return new IdResp()
            ..success = false
            ..error = "WRONG_USER_OR_PASSWORD";
    }
    
    user.password = encryptPassword(user.password);
    
    
    UserAdmin foundUser = await dbConn.findOne ('user', UserAdmin, {"email": user.email, "password": user.password});
    
    //User doesnt exist
    if (foundUser == null)
    {
        return new IdResp()
            ..success = false
            ..error = "WRONG USERNAME OR PASSWORD";
    }
    
    
    session["id"] = StringToId(foundUser.id);
    
    Set roles = new Set();
    
    if (foundUser.admin)
    {
        roles.add(ADMIN);
    }
    
    session["roles"] = roles;
    
    return new IdResp()
        ..success = true
        ..id = foundUser.id;
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
    return new Resp()
        ..success = app.request.session['id'] != null;
}

@app.Route ('/private/userlist')
@Secure(ADMIN)
@Encode()
listUsers(@app.Attr() MongoDb dbConn) {
  
  return dbConn.find('user', UserAdmin);
  
}

