part of aristadart.client;

@Component
(
    selector : 'admin-target',
    templateUrl: 'components/admin/target.html',
    useShadowDom: false
)
class TargetVista{
    
    bool updatePending = true;
    bool get queryPending => updatePending ? true : null;
    Router router;
    List<LocalImageTarget> targets = [];
    
    TargetVista(this.router)
    {
        setTargets();
    }
    
    setTargets()
    {
        new ClientLocalTargetServices()
        .Find (updatePending: queryPending, findOwners: true)
        .then((list){
           
        targets = list;
        })
        .catchError(printReqError, test: ifProgEvent);
    }
    
    uploadModel(LocalImageTarget target, dom.MouseEvent event)
    {
        dom.FormElement form = getFormElement (event);
        
        new ClientLocalTargetServices(target).UpdateFiles(form).then((_target)
        {
            _target.owner = target.owner;
            var index = targets.indexOf (target);
            targets.remove (target);
            targets.insert (index, _target);
        })
        .catchError(printReqError, test: ifProgEvent);
    }
    
    publish (LocalImageTarget target)
    {
        
        new ClientLocalTargetServices(target).Publish().then((_target){
            
        if (! _target.updatePending && queryPending == true)
        {
            targets.removeWhere((obj) => obj.id == _target.id);
        }
        })
        .catchError(printReqError, test: ifProgEvent);
    }
    
    setPublic (LocalImageTarget target)
    {
        var delta = new LocalImageTarget()
            ..public = target.public;
        
        new ClientLocalTargetServices(target).UpdateGeneric(delta).then((_target){
            
        target.public = _target.public;
        });
    }
}