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
    
    uploadModel(ObjetoUnitySend obj, String system) async
    {
        switch ( system )
        {
            case 'ios':
                await requestDecoded
                (
                    ObjetoUnitySendResp,
                    Method.PUT,
                    'private/objetounity/${obj.modelIdIOS}/modelfile/${system}'
                );//ojo con id y modelfile
                break;
            case 'mac':
                await requestDecoded
                (
                    ObjetoUnitySendResp,
                    Method.PUT,
                    'private/objetounity/${obj.modelIdMAC}/modelfile/${system}'
                );
                break;
            case 'android':
                await requestDecoded
                (
                    ObjetoUnitySendResp,
                    Method.PUT,
                    'private/objetounity/${obj.modelIdAndroid}/modelfile/${system}'
                );
                break;
            case 'windows':
                await requestDecoded
                (
                    ObjetoUnitySendResp,
                    Method.PUT,
                    'private/objetounity/${obj.modelIdWindows}/modelfile/${system}'
                );
                break;
            default:
                break; 
        }   
    }
}

class ModelAdminInfo{
    ObjetoUnitySend model;
    User user;
}