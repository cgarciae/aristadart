part of arista_server;

const String ADMIN = "ADMIN";

class Col
{
    static String user = 'user';
    static String evento = 'evento';
}

//A public service. Anyone can create a new user
@app.Route("/user/add", methods: const[app.POST])
addUser(@app.Attr() MongoDb dbConn, @Decode() UserSecure user) 
{
    user.username = user.username.trim();
    
    return dbConn.findOne ('user', UserSecure, {"username": user.username})
    .then((UserSecure foundUser) 
    {
        return {"success": false, "error": "USER_EXISTS"};
    })
    .catchError((error)
    {
        print (error);
        user.password = encryptPassword(user.password);
          
        return dbConn
        .insert('user', user)
        .then((_) => {"success": true});
    }); 
}

@app.Route("/user/login", methods: const[app.POST])
login(@app.Attr() MongoDb dbConn, @app.Body(app.JSON) QueryMap user) 
{   
    
    if (user.username == null || user.password == null)
    {
        return {"success": false, "error": "WRONG_USER_OR_PASSWORD"};
    }
    
    user.password = encryptPassword(user.password);
    
    
    return dbConn.findOne('user', User, {"username": user.username, "password": user.password})
    .then((User foundUser) 
    {
        //User doesnt exist
        if (foundUser == null)
        {
            return 
            {
                "success": false,
                "error": "WRONG USERNAME OR PASSWORD"
            };
        }
        
        
        
        session["id"] = StringToId(foundUser.id);
        session["user"] = foundUser;
        
        Set roles = new Set();
        
        if (foundUser.admin)
        {
            roles.add(ADMIN);
        }
        
        session["roles"] = roles;
        
        return 
        {
            "success": true,
            "id" : foundUser.id
        };
    });
}

@app.Route ('/private/username')
getUsername ()
{
    return app.request.session['username'];
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
    app.request.session.destroy();
    return {"success": true};
}

@app.Route("/user/loggedin")
isLoggedIn() 
{
    
    return {"success": app.request.session['user'] != null};
}

@app.Route ('/private/userlist')
@Secure(ADMIN)
@Encode()
listUsers(@app.Attr() MongoDb dbConn) {
  
  return dbConn.find('user', User);
  
}

