part of arista_client;

@Component
(
    selector : 'model',
    templateUrl: 'components/admin/model.html',
    useShadowDom: false
)
class ModelVista{
    
    List<ModelAdminInfo> infoList = [ ];
    
    Router router;
    ModelVista(this.router){
        setModels();
    }
    
    setModels() async
    {
        ObjetoUnitySendListResp resp = await requestDecoded
        (
            ObjetoUnitySendListResp,
            Method.GET,
            'private/objetounity/pending'
        );
        if(! resp.success){
            return print(resp.error);
        }
        for( ObjetoUnitySend obj in resp.objs ){
            ModelAdminInfo info = new ModelAdminInfo();
            info.model = obj;
            UserResp userResp = await requestDecoded
            (
                UserResp,
                Method.GET,
                'user/${obj.owner}'
            );
            if(! userResp.success)
            {
                print(userResp.error);
                continue;
            }
            info.user = userResp.user;
            infoList.add(info);
        }
        
    }
    
    uploadModel(ModelAdminInfo info, String system, dom.MouseEvent event) async
    {
        dom.FormElement form = getFormElement (event);
        
        ObjetoUnitySendResp resp = await formRequestDecoded
        (   
            ObjetoUnitySendResp,
            Method.PUT,
            'private/objetounity/${info.model.modelIdWindows}/modelfile/${system}',
            form
        );
        
        if(!resp.success)
            return resp.error;
        info.model = resp.obj;
        print('completo??'+resp.success.toString());
        info.success = resp.success;
    }
}

class ModelAdminInfo{
    ObjetoUnitySend model;
    User user;
    bool success = false; 
}