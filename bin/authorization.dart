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
    
    
    manager.addErrorHandler
    (
        new app.ErrorHandler.conf(403, urlPattern: r'/.*'), 
        "Unauthorized Request", 
        (_) => "Unauthorized request, must loggin"
    );
    
    manager.addRouteWrapper(Private, (metadata, Map<String,String> pathSegments, injector, app.Request request, route) async {
    
        var id = request.headers.authorization;
                
        if (id == null)
            return new app.ErrorResponse(403, {"error": "authorization header expected"});
        
        print ("1");
        
        var user = await dbConn.findOne
        (
            Col.user,
            User,
            where.id(StringToId(id))
        );
        
        if (user == null)
            return new app.ErrorResponse(403, {"error": "Invalid ID: user does not exist"});
        
        
        return route(pathSegments, injector, request);
    
  }, includeGroups: true);
    
  
}

