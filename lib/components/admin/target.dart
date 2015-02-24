part of aristadart.client;

@Component
(
    selector : 'admin-target',
    templateUrl: 'components/admin/target.html',
    useShadowDom: false
)
class TargetVista{
    
    List<LocalTargetAdminInfo> infoList = [];
    Router router;
    
    TargetVista(this.router)
    {
        setModels();
    }
    
    setModels()
    {
        requestDecoded
        (
            LocalImageTargetSendListResp,
            Method.GET,
            'private/${Col.localTarget}/pending'
        )
        .then((LocalImageTargetSendListResp resp){
        
        if(resp.failed)
        {
            return print(resp.error);
        }
        
        infoList.clear();
        
        for (LocalImageTargetSend obj in resp.objs)
        {
            LocalTargetAdminInfo info = new LocalTargetAdminInfo();
            info.target = obj;
            
            if (nullOrEmpty (obj.owner))
            {
                print("Owner undefined");
                continue;
            }
            
            requestDecoded
            (
                UserResp,
                Method.GET,
                'user/${obj.owner}'
            ).then((UserResp userResp){
            
            if (userResp.failed)
            {
                print(userResp.error);
                return;
            }
            
            info.user = userResp.user;
            infoList.add (info);
            
            });
        }
        });
    }
    
    uploadModel (LocalTargetAdminInfo info, String extension, dom.MouseEvent event)
    {
        print ("Uploading to $extension");
        
        dom.FormElement form = getFormElement (event);
        
        formRequestDecoded
        (   
            LocalImageTargetSendResp,
            Method.PUT,
            'private/${Col.localTarget}/${info.target.id}/targetfile/${extension}',
            form
        )
        .then((LocalImageTargetSendResp resp){
        
        if(resp.failed)
            return print (resp.error);
        
        
        info.target = resp.obj;
        
        });
    }
    
    publish (LocalTargetAdminInfo info)
    {
        
        requestDecoded
        (
            Resp,
            Method.GET,
            'private/${Col.localTarget}/${info.target.id}/publish'
        )
        .then((Resp resp){
        
        if (resp.success)
            setModels();
        else
            print (resp.error);
        
        });
    }
}

class LocalTargetAdminInfo
{
    LocalImageTargetSend target;
    User user;
}