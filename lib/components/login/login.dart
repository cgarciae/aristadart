part of arista_client;

@Component
(
    selector : "login",
    templateUrl: 'components/login/login.html',
    useShadowDom: false
)
class Login extends ShadowRootAware
{
    
    UserSecure user = new UserSecure();
    Router router;
    
    bool nuevo = false;
    
    Login (this.router)
    {
        
    }
    
    upload (dom.MouseEvent event)
    {
        dom.FormElement form = event.target as dom.FormElement;
        
        formRequestDecoded('upload', form, Resp).then((Resp resp)
        {
            print (resp.success);
        });
    }
    
      onShadowRoot(dom.ShadowRoot root){}
//    {
//        dom.InputElement uploadInput = dom.querySelector('#upload');
//                
//        uploadInput.onChange.listen((dom.Event e) 
//        {
//            // read file content as dataURL
//            final files = uploadInput.files;
//            
//            if (files.length == 1) 
//            {
//                final file = files[0];
//                final reader = new dom.FileReader();
//                
//                reader.readAsDataUrl (file);
//                
//                reader.onLoad.listen((_) 
//                {
//                    print (reader.result);
//                    print (reader.result.runtimeType);
//                    
//                    dataRequestDecoded('upload2', reader.result, Resp).then((Resp resp)
//                    {
//                        print ('Success ${resp.success}');
//                    });
//                });
//            }
//        });
//    }
    
    login ()
    {
        jsonRequestDecoded('/user/login', user, IdResp).then(doIfSuccess((IdResp obj) 
        {
            storage['id'] = obj.id;
            router.go('home', {});
        }));
    }
    
    nuevoUsuario()
    {
        nuevo = true;
        router.go ('login.nuevo', {});
    }
    
    

    /// send data to server
    sendDatas(dynamic data) 
    {
        final req = new dom.HttpRequest();
        
        req.onReadyStateChange.listen((dom.Event e) 
        {
            if (req.readyState == dom.HttpRequest.DONE && (req.status == 200 || req.status == 0)) 
            {
                dom.window.alert("upload complete");
            }
        });
        
        req.open ("POST", "http://127.0.0.1:8080/upload");
        req.send (data);
    }
}

