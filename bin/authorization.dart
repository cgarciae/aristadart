part of aristadart.server;

class Secure {
  
  final String role;
  
  const Secure(this.role);
  
}


void AuthorizationPlugin(app.Manager manager) {
  
    
    manager.addRouteWrapper(Secure, (metadata, Map<String,String> pathSegments, injector, app.Request request, route) {
    
        String role = (metadata as Secure).role;
        Set userRoles = app.request.session["roles"];
        
        if (!userRoles.contains(role)) 
        {
            throw new app.ErrorResponse(401, {"error": "NOT_AUTHORIZED"});
        }
    
        return route(pathSegments, injector, request);
    
  }, includeGroups: true);
    
  
}


class Private {
  
  const Private();
  
}


void AuthenticationPlugin(app.Manager manager) {
    
    
    manager.addRouteWrapper(Private, (metadata, Map<String,String> pathSegments, injector, app.Request request, route) async {
    
        var id = request.headers.authorization;
                
        if (id == null)
            return {"error": "Authentication Error: Authorization header expected"};
        
        print ("1");
        
        User user;
        try
        {
            user = await db.findOne
            (
                Col.user,
                User,
                where.id(StringToId(id))
            );
        }
        on ArgumentError catch (e)
        {
            return {"error": "Authentication Error: ID length must be 24"};
        }
        
        if (user == null)
            return  {"error": "Authentication Error: User does not exist"};
        
        
        return route(pathSegments, injector, request);
    
  }, includeGroups: true);
    
  
}

