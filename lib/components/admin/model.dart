part of aristadart.client;

@Component
(
    selector : 'model',
    templateUrl: 'components/admin/model.html',
    useShadowDom: false
)
class ModelVista{
    
    List<ModelAdminInfo> infoList = [];
    Router router;
    
    ModelVista(this.router)
    {
        setModels();
    }
    
    setModels()
    {
        requestDecoded
        (
            ObjetoUnitySendListResp,
            Method.GET,
            'private/objetounity/pending'
        )
        .then((ObjetoUnitySendListResp resp){
        
        if(! resp.success)
        {
            return print(resp.error);
        }
        
        infoList.clear();
        
        for (ObjetoUnitySend obj in resp.objs)
        {
            ModelAdminInfo info = new ModelAdminInfo();
            info.model = obj;
            
            if (! notNullOrEmpty(obj.owner))
            {
                print("Owner undefined");
                continue;
            }
            
            requestDecoded
            (
                UserResp,
                Method.GET,
                'user/${obj.owner}'
            )
            .then((UserResp userResp){
            
            if(! userResp.success)
            {
                print(userResp.error);
                return;
            }
            
            
            info.user = userResp.user;
            infoList.add(info);
        });
        }
        });
    }
    
    uploadScreenshot (dom.MouseEvent event, ObjetoUnitySend obj)
    {
        dom.FormElement form = getFormElement(event);
        
        formRequestDecoded
        (
            IdResp,
            Method.POST,
            'private/objetounity/${obj.id}/screenshot',
            form
        )
        .then((IdResp idResp){
            
        if (! idResp.success)
            return print (idResp.error);
        
        obj.screenshotId = idResp.id;
        
        });
    }
    
    uploadModel(ModelAdminInfo info, String system, dom.MouseEvent event)
    {
        print ("Uploading to $system");
        
        dom.FormElement form = getFormElement (event);
        
        formRequestDecoded
        (   
            ObjetoUnitySendResp,
            Method.PUT,
            'private/objetounity/${info.model.id}/modelfile/${system}',
            form
        )
        .then((ObjetoUnitySendResp resp){
        
        if(! resp.success)
            return print (resp.error);
        
        info.model = resp.obj;
        
        });
    }
    
    publish (ModelAdminInfo info)
    {
        
        requestDecoded
        (
            Resp,
            Method.GET,
            'private/objetounity/${info.model.id}/publish'
        )
        .then((Resp resp){
        
        if (resp.success)
            setModels();
        else
            print (resp.error);
        
        });
    }
    
    //Función para guardar el campo NameGameObject del modelo
    guardarModel (ModelAdminInfo info) async
    {        
        Resp resp = await jsonRequestDecoded
        (
            Resp,
            Method.PUT,
            'private/objetounitysend/${info.model.id}/guardarObjUnitySend',
            info.model
        );
        
        if (resp.success)
            setModels();
        else
            print (resp.error);
    }
}

class ModelAdminInfo
{
    ObjetoUnitySend model;
    User user;
}