part of aristadart.client;

class ClientLocalTargetServices extends ClientService<LocalImageTarget>
{
    ClientLocalTargetServices ([LocalImageTarget source]) : super (source, Col.localTarget);
    
    Future<LocalImageTarget> NewOrUpdateUserFile (dom.FormElement form)
    {
        return privateForm(Method.PUT, '$href/image', form);
    }
    
    Future<LocalImageTarget> Publish ()
    {
        return private (Method.PUT, '$href/publish');
    }
    
    Future<LocalImageTarget> UpdateFiles (dom.FormElement form)
    {
        return privateForm(Method.PUT, '$href/files', form);
    }
    
    Future<List<LocalImageTarget>> All ({bool updatePending, bool public})
    {
        Map query = {};
                
        if (updatePending != null)
            query['updatePending'] = updatePending;
        
        if (public != null)
            query['public'] = public;
        
        return Requester.private (LocalImageTarget, Method.GET, '$pathBase/all', params: query);
    }
    
    Future<List<LocalImageTarget>> Find ({bool updatePending,
                                          String userId,
                                          bool public,
                                          bool findOwners})
    {
        Map query = {};
                        
        if (updatePending != null)
            query['updatePending'] = updatePending;
        
        if (public != null)
            query['public'] = public;
        
        if (userId != null)
            query['userId'] = userId;

        if (findOwners != null)
            query['findOwners'] = findOwners;
        
        return Requester.private (LocalImageTarget, Method.GET, 
                                  '$pathBase/find', params: query);
    }
}