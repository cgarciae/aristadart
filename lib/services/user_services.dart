part of arista_server;



//A public service. Anyone can create a new user
@app.Route("/new/user", methods: const[app.POST])
@Encode()
addUser(@app.Attr() MongoDb dbConn, @Decode() CompleteUser user) 
{
    user.username = user.username.trim();
    
    return dbConn.findOne (Col.user, CompleteUser, {"username": user.username})
    .then((CompleteUser foundUser) 
    {
        if (foundUser != null)
        {
            return new Resp()
                ..success = false
                ..error = "User Exists";
        }    

        user.id = new ObjectId().toHexString();
        user.password = encryptPassword (user.password);
        user.admin = false;
          
        return dbConn.insert(Col.user, user).then((_) 
        {
            return new IdResp()
                ..success = true
                ..id = user.id;
        });
    }); 
}

@app.Route("/user/login", methods: const[app.POST])
@Encode()
login(@app.Attr() MongoDb dbConn, @Decode() UserSecure user)
{   
    
    if (user.username == null || user.password == null)
    {
        return new Resp()
            ..success = false
            ..error = "WRONG_USER_OR_PASSWORD";
    }
    
    user.password = encryptPassword(user.password);
    
    
    return dbConn.findOne('user', User, {"username": user.username, "password": user.password})
    .then((User foundUser)
    {
        //User doesnt exist
        if (foundUser == null)
        {
            return new Resp()
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
    });
}


@app.Route ('/private/user/panelinfo')
@Encode()
panelInfo (@app.Attr() MongoDb dbConn)
{
    
    var userId = session['id'];
    
    return dbConn.findOne(Col.user, User, where.id(userId))
    .then((User user)
    {
    
        var eventIds = user.eventos.map(StringToId).toList();
        
        return dbConn.find(Col.evento, Evento, where.oneFrom('_id', eventIds))
        .then((List<Evento> eventos)
        {
            return new PanelInfo()
                ..user = user
                ..eventos = eventos;
        });
    });
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
  
  return dbConn.find('user', User);
  
}

