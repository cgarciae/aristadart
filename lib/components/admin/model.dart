part of aristadart.client;

@Component
(
    selector : 'model',
    templateUrl: 'components/admin/model.html',
    useShadowDom: false
)
class ModelVista{
    
    Router router;
    List<ObjetoUnity> models = [];
    ClientObjetoUnityServices services;
    
    //Set null para buscar todos
    bool updatePending = true;
    bool cambios = false;
    
    bool get queryPending => updatePending ? true : null;
    
    ModelVista(this.router)
    {
        services = new ClientObjetoUnityServices();
        setModels();
        
    }
    
    setModels()
    {
        services.Find(updatePending: queryPending, findOwners: true).then((list){
                    
        models = list;
        })
        .catchError(printReqError, test: ifProgEvent);
    }
    
    uploadScreenshot (dom.MouseEvent event, ObjetoUnity obj)
    {
        dom.FormElement form = getFormElement(event);
        var fileServices = new ClientFileServices(obj.screenshot);
        
        return new Future((){
        if (obj.screenshot != null)
        {
            return fileServices.UpdateFile (form).then((_file){
             
            obj.screenshot = _file;
            });
        }
        else
        {
            return fileServices.NewOrUpdate (form).then((_file){
                         
            obj.screenshot = _file;
            });
        }
        })
        .then((_){
        var delta = new ObjetoUnity()
            ..screenshot = (new FileDb()
                ..id = obj.screenshot.id);
        
        return new ClientObjetoUnityServices(obj).UpdateGeneric(delta);
        })
        .catchError(printReqError, test: ifProgEvent);;
    }
    
    uploadModel(ObjetoUnity model, dom.MouseEvent event)
    {
        dom.FormElement form = getFormElement (event);
        
        new ClientObjetoUnityServices(model).UpdateModels(form).then((_model)
        {
            _model.owner = model.owner;
            
            var index = models.indexOf (model);
            models.remove (model);
            
            models.insert (index, _model);
        })
        .catchError(printReqError, test: ifProgEvent);;
    }
    
    publish (ObjetoUnity model)
    {
        
        new ClientObjetoUnityServices(model).Publish().then((_modelo){
            
        if (! _modelo.updatePending && queryPending == true)
        {
            models.removeWhere((obj) => obj.id == _modelo.id);
        }
        })
        .catchError(printReqError, test: ifProgEvent);
    }
    
    setPublic (ObjetoUnity model)
    {
        var delta = new ObjetoUnity()
            ..public = model.public;
        
        new ClientObjetoUnityServices(model).UpdateGeneric(delta).then((_obj){
            
        model.public = _obj.public;
        });
    }
    
    nuevoTag (ObjetoUnity obj)
    {
        if (obj.tags == null)
            obj.tags = [];
        
        obj.tags.add ("Tag");
        
        cambios = true;
        guardarTags (obj);
    }
    
    eliminarTag (ObjetoUnity obj, String tag)
    {
        obj.tags.remove (tag);
        
        cambios = true;
        guardarTags (obj);
    }
    
    cambiarTag (ObjetoUnity obj, String tag, int index)
    {
        obj.tags[index] = tag;
        cambios = true;
    }
    
    guardarTags (ObjetoUnity obj)
    {
        if (cambios)
        {
            cambios = false;
            
            var delta = new ObjetoUnity()
                ..tags = obj.tags;
            
            print (encode(delta));
            
            new ClientObjetoUnityServices(obj).UpdateGeneric (delta).then((_obj){
               
            obj.tags = _obj.tags;
            })
            .catchError(printReqError, test: ifProgEvent);
        }
    }
    
}