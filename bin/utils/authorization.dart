part of aristadart.server;



class Private {
  final int securityLevel;
  const Private([this.securityLevel = 0]);
  
}


void AuthenticationPlugin(app.Manager manager) {
    
    
    manager.addRouteWrapper(Private, (metadata, Map<String,String> pathSegments, injector, 
                                        app.Request request, app.RouteHandler route) async {
        
        var id = request.headers.authorization;
        
        //print("Private");       
        if (id == null)
            return new Resp()..error = "Authentication Error: Authorization header expected";
        
        ProtectedUser user;
        try
        {
            user = await db.findOne
            (
                Col.user,
                ProtectedUser,
                where.id(StringToId(id))
            );
        }
        on ArgumentError catch (e)
        {
            return new Resp()..error = "Authentication Error: ID length must be 24";
        }
        catch (e)
        {
            return new Resp()..error = "Authentication Error Desconocido: $e";
        }
        
        if (user == null)
            return new Resp()..error = "Authentication Error: User does not exist";
        
        if ((metadata as Private).securityLevel > 0 && ! user.admin)
            return new Resp()..error = "Error de Autorizacion: No se tiene permisos para este recurso";
        
        return route(pathSegments, injector, request);
    
  }, includeGroups: true);
}

class Catch 
{  
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

