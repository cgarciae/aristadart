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
    List<ObjetoUnity> models;
    ClientObjetoUnityServices services;
    
    //Set null para buscar todos
    bool updatePending = true;
    bool queryPending = true;
    
    bool get queryUpdatePending => queryPending ? updatePending : null;
    
    ModelVista(this.router)
    {
        setModels();
        
        services = new ClientObjetoUnityServices();
        
    }
    
    setModels()
    {
        services.Find(updatePending: updatePending, findOwners: true).then((list){
                    
        models = list;
        });
    }
    
    uploadScreenshot (dom.MouseEvent event, ObjetoUnity obj)
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
    
    uploadModel(ObjetoUnity model, dom.MouseEvent event)
    {
        dom.FormElement form = getFormElement (event);
        
        new ClientObjetoUnityServices(model).UpdateModels(form).then((_model)
        {
            _model.owner = model.owner;
            
            var index = models.indexOf(model);
            models.remove(model);
            
            models.insert(index, _model);
        });
    }
    
    publish (ObjetoUnity model)
    {
        
        new ClientObjetoUnityServices(model).Publish().then((_modelo){
            
        //No es redundante, puede ser null
        if (queryUpdatePending == true)
        {
            models.removeWhere((obj) => obj.id == _modelo.id);
        }
        });
    }
    
    //Función para guardar el campo NameGameObject del modelo
    guardarModel (ModelAdminInfo info)
    {        
        jsonRequestDecoded
        (
            Resp,
            Method.PUT,
            'private/objetounitysend/${info.model.id}/guardarObjUnitySend',
            info.model
        )
        .then((Resp resp){
            if (resp.success)
                setModels();
            else
                print (resp.error);
        });
        
        
    }
    
    saveNameGameObject(ObjetoUnitySend obj)
    {
        print (obj);
        
        jsonRequestDecoded
        (
            ObjetoUnitySend,
            Method.PUT,
            'private/objetounity/${obj.id}',
            new ObjetoUnitySend()
                ..nameGameObject = obj.nameGameObject
        )
        .then ((ObjetoUnitySend resp){
        
        print (encodeJson(resp));
        
        });
    }
}

class ModelAdminInfo
{
    ObjetoUnitySend model;
    User user;
}