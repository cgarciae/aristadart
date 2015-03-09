part of aristadart.client;

class ClientCloudTargetServices extends ClientService<CloudTarget>
{
    ClientCloudTargetServices ([CloudTarget source]) : super (source, Col.cloudTarget);
    
    Future<CloudTarget> NewFromImage (dom.FormElement form)
    {
        return privateForm(Method.POST, '$pathBase/newFromImage', form);
    }
    
    Future<CloudTarget> UpdateFromImage (dom.FormElement form)
    {
        return privateForm(Method.PUT, '$href/updateFromImage', form);
    }
}