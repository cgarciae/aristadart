part of aristadart.client;

class ClientCloudTargetServices extends ClientService<CloudTarget>
{
    ClientCloudTargetServices ([CloudTarget source]) : super (source, Col.cloudTarget);
    
    Future<CloudTarget> New (String eventoId)
    {
        return NewGeneric(queryParams: {"eventoId": eventoId});
    }
    
    Future<CloudTarget> NewFromImage (dom.FormElement form, String eventoId)
    {
        if (eventoId == null)
            throw new ArgumentError.notNull ("eventoId requerido");
        
        return privateForm(Method.POST, '$pathBase/newFromImage', form,
                           params: {"eventoId" : eventoId});
    }
    
    Future<CloudTarget> UpdateFromImage (dom.FormElement form)
    {
        return privateForm(Method.PUT, '$href/updateFromImage', form);
    }
}