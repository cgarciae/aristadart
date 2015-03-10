part of aristadart.client;

class ClientObjetoUnityServices extends ClientService<ObjetoUnity>
{
    ClientObjetoUnityServices ([ObjetoUnity source]) : super (source, Col.objetoUnity);
    
    Future<ObjetoUnity> NewOrUpdateUserFile (dom.FormElement form)
    {
        return privateForm(Method.POST, '$href/userFile', form);
    }
    
    Future<ObjetoUnity> Publish ()
    {
        return private (Method.PUT, '$href/publish');
    }
    
    Future<ObjetoUnity> UpdateModels (dom.FormElement form)
    {
        return privateForm(Method.PUT, '$href/models', form);
    }
    
    Future<List<ObjetoUnity>> All ({bool updatePending, bool active, bool public})
    {
        Map query = {};
        
        if (updatePending != null)
            query['updatePending'] = updatePending;
        
        if (active != null)
            query['active'] = active;
        
        if (public != null)
            query['public'] = public;
        
        return Requester.private (ObjetoUnity, Method.GET, '$pathBase/all', params: query);
    }
    
    Future<List<ObjetoUnity>> Find ({bool updatePending,
                                    String userId,
                                    bool active,
                                    bool public,
                                    bool findOwners})
    {
        //Definir query object
        Map query = {};
     
        //Buscar usuario
        if  (userId != null)
            query["userId"] = userId;
    
        //Agregar pending
        if (updatePending != null)
            query["updatePending"] = updatePending;
    
        //Agregar pending
        if (updatePending != null)
            query["active"] = active;
        
        if (findOwners != null)
            query["findOwners"] = findOwners;
          
        return Requester.private (ObjetoUnity, Method.GET, 
                                  '$pathBase/find', params: query);
    
    }
        
                                        
}