part of arista_client;

@Component
(
    selector : 'model',
    templateUrl: 'components/admin/model.html',
    useShadowDom: false
)
class ModelVista{
    
    List<ModelAdminInfo> modelos = [ ];
    
    Router router;
    ModelVista(this.router){
        getModels();
    }
    
    getModels() async
    {
        ObjetoUnitySendListResp resp = await requestDecoded(ObjetoUnitySendListResp, Method.GET, ''); //falta ruta
        if(! resp.success){
            return print(resp.error);
        }
        for( ObjetoUnitySend obj in resp.objs ){
            ModelAdminInfo info = new ModelAdminInfo();
            info.model = obj;
            User resp1 = await requestDecoded(User, Method.GET, '');
        }
    }
    
    Future<User> getUser(ObjetoUnitySend modelo) async
    {
        
        return await requestDecoded(User, Method.GET, '/user/${modelo.owner}');
    }
    
    uploadModel(String system) async
    {
        await requestDecoded(ObjetoUnitySendResp, Method.PUT, 'private/objetounity/:id/{{modelo}}/{{system}}');//ojo con id y modelfile
    }
}

class ModelAdminInfo{
    ObjetoUnitySend model;
    User user;
}