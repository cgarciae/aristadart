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
    
    
    manager.addRouteWrapper(Private, (metadata, Map<String,String> pathSegments, injector, app.Request request, app.RouteHandler route) async {
        
        var id = request.headers.authorization;
        
        //print("Private");       
        if (id == null)
            return new Resp()..error = "Authentication Error: Authorization header expected";
        
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
            return new Resp()..error = "Authentication Error: ID length must be 24";
        }
        
        if (user == null)
            return new Resp()..error = "Authentication Error: User does not exist";
        
        
        return route(pathSegments, injector, request);
    
  }, includeGroups: true);
}

class Catch {
  
  const Catch();
  
}


void ErrorCatchPlugin(app.Manager manager) {
    
    
    manager.addRouteWrapper(Catch, (metadata, Map<String,String> pathSegments, 
                                    injector, app.Request request, 
                                    app.RouteHandler route) async {
        //print("Catch");
        try
        {
            var result = route (pathSegments, injector, request);
            
            if (result is Future)
                return await result;
            else
                return result;
        }
        catch (e, s)
        {
            return new Resp()
                ..error = "$e     $s";
        }
    
  }, includeGroups: true);
}

