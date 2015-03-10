part of aristadart.client;

class ClientObjetoUnityServices extends ClientService<ObjetoUnity>
{
    ClientObjetoUnityServices ([ObjetoUnity source]) : super (source, Col.objetoUnity);
    
    Future<ObjetoUnity> NewOrUpdateUserFile (dom.FormElement form)
    {
        return privateForm(Method.POST, '$href/userFile', form);
    }
    
    Future<ObjetoUnity> Publish (String id)
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
}