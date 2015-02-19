part of arista_client;

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
    
    setModels() async
    {
        LocalImageTargetSendListResp resp = await requestDecoded
        (
            LocalImageTargetSendListResp,
            Method.GET,
            'private/${Col.localTarget}/pending'
        );
        
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
            
            UserResp userResp = await requestDecoded
            (
                UserResp,
                Method.GET,
                'user/${obj.owner}'
            );
            
            if (userResp.failed)
            {
                print(userResp.error);
                continue;
            }
            
            info.user = userResp.user;
            infoList.add (info);
        }
        
    }
    
    uploadModel (LocalTargetAdminInfo info, String extension, dom.MouseEvent event) async
    {
        print ("Uploading to $extension");
        
        dom.FormElement form = getFormElement (event);
        
        LocalImageTargetSendResp resp = await formRequestDecoded
        (   
            LocalImageTargetSendResp,
            Method.PUT,
            'private/${Col.localTarget}/${info.target.id}/targetfile/${extension}',
            form
        );
        
        if(resp.failed)
            return print (resp.error);
        
        
        info.target = resp.obj;
    }
    
    publish (LocalTargetAdminInfo info) async
    {
        
        Resp resp = await requestDecoded
        (
            Resp,
            Method.GET,
            'private/${Col.localTarget}/${info.target.id}/publish'
        );
        
        if (resp.success)
            setModels();
        else
            print (resp.error);
    }
}

class LocalTargetAdminInfo
{
    LocalImageTargetSend target;
    User user;
}