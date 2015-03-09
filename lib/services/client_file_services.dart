part of aristadart.client;

class ClientFileServices extends ClientService<FileDb>
{
    ClientFileServices ([FileDb source]) : super (source, "file");
  
    Future<FileDb> NewOrUpdate (dom.FormElement form, 
                        {String type, String system})
    {
        
        Map<String, String> params = {};
        
        if (type != null)
            params['type'] = type;
        
        if (system != null)
            params['system'] = system;
        
        return Requester.privateForm
        (
            FileDb,
            Method.POST,
            pathBase,
            form,
            params: params
        );
    }
    
    Future<FileDb> GetMetadata ()
    {
        if (href == null)
            return new Future.value(new FileDb()
                ..error = "Client Error: href es null");
        
        return Requester.decoded
        (
            FileDb,
            Method.GET,
            '$href/metadata'
        );
    }
    
    Future<FileDb> UpdateFile (dom.FormElement form)
    {
        if (href == null)
            return new Future.value(new FileDb()
                ..error = "Client Error: href es null");
        
        return Requester.privateForm
        (
            FileDb,
            Method.PUT,
            href,
            form
        );
    }
}