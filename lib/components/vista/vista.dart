part of aristadart.client;

@Component
(
    selector : "vista",
    templateUrl: 'components/vista/vista.html',
    useShadowDom: false
)
class VistaVista
{
    Router router;
    VistaExportable vista = new VistaExportable();
    String eventoID;
    String tituloVista='';
    
    List<TipoDeVista> tiposDeVista = const 
    [
        const TipoDeVista (
                'ConstruccionRAJS, Assembly-CSharp', 
                'Construcción RA', 
                'Experimenta tu inmueble en Realidad Aumentada'),
                
        const TipoDeVista (
                'InfoContactoJS, Assembly-CSharp', 
                'Informacion y Contacto', 
                'Vista con informacion general y opciones de contacto'),
                
        const TipoDeVista (
                'MultimediaJS, Assembly-CShar',
                'Multimedia',
                'Vista para carrusel de y imagenes, proximamente videos'
                ),
                
        const TipoDeVista (
                'MapaConstruccionJS, Assembly-CSharp',
                'Ubicación',
                'Muestra la ubicación de tu proyecto facilmente'
                )
     ];
    
    List<TipoElementoInfo> tiposElementoInfo = const 
    [
        const TipoElementoInfo (
                'TituloInfoJS, Assembly-CSharp', 
                'Titulo', 
                'Experimenta tu inmueble en Realidad Aumentada'),
                
        const TipoElementoInfo (
                'ImagenInfoJS, Assembly-CSharp', 
                'Imagen', 
                'Vista con informacion general y opciones de contacto'),
                
        const TipoElementoInfo (
                'InfoTextoJS, Assembly-CSharp',
                'Descripción',
                'Vista para carrusel de y imagenes, proximamente videos'
                )
     ];
    
    List<TipoElementoContacto> tiposElementoContacto = const
    [
        const TipoElementoContacto (
                'LlamarContactoJS, Assembly-CSharp' ,
                'Contactar',
                'Permite llamar con un toque'
        )
    ];
    
    
    VistaVista (RouteProvider routeProvider, this.router)
    {
        initVista (routeProvider);
        print("constructor vistaVista");
    }
    
    initVista (RouteProvider routeProvider)
    {
        var id = routeProvider.parameters['vistaID'];
        eventoID = routeProvider.parameters['eventoID'];
        
        if (id == null)
        {
            print ('NUEVA VISTA');
            //Crear nuevo evento
            return newFromCollection (Col.vista).then((IdResp resp){
            
            if (resp.success)
            {
                vista.id = resp.id;
            }
            else
            {
                print (resp.error);
            }
            });
        }
        else
        {
            print ('CARGAR VISTA');
            //Cargar vista
            return getFromCollection
            (
                VistaExportableResp, 
                'vista', 
                id
            )
            .then((VistaExportableResp resp){
            
            if (! resp.success)
                return print (resp.error);

            
            print (encodeJson (resp.vista));
            
            vista = resp.vista;
            icono = vista.icon.urlTextura.split (r'/').last;
            urlIcono = 'images/webapp/${icono}.png';
            tituloVista =
                    tiposDeVista
                    .where((tipo)=> tipo.type__ == vista.type__)
                    .map((TipoDeVista t) => t.nombre)
                    .first; 
            
            
            if (notNullOrEmpty (vista.localTargetId))
            {
                getFromCollection
                (
                    LocalImageTargetSendResp,
                    Col.localTarget,
                    vista.localTargetId
                )
                .then((LocalImageTargetSendResp targetResp){
                
                if (! targetResp.success)
                    return print (targetResp.error);
                
                vista.localTarget = targetResp.obj;
                });
            }
            
            if (notNullOrEmpty (vista.objetoUnityId))
            {
                getFromCollection
                (
                    ObjetoUnitySendResp,
                    'objetounity',
                    vista.objetoUnityId
                )
                .then((ObjetoUnitySendResp objResp){
                
                if (! objResp.success)
                    return print (objResp.error);
                
                vista.objetoUnity = objResp.obj;
                });
            }
            });
        }
    }
    
    saveAndLeave ()
    {
        print ('Local Target Id: ${vista.localTargetId}');
        return saveInCollection (Col.vista, vista).then((Resp resp){

        if (resp.success)
            router.go('evento', {'eventoID' : eventoID});
        else
            print (resp.error);
        
        saveObjetoUnity();
        saveLocaltarget();
        });
    }
    
    saveAndStay ()
    {
        print (encodeJson(vista));
        
        return saveInCollection (Col.vista, vista).then((Resp resp){
        

        if (! resp.success)
            print (resp.error);
        
        saveObjetoUnity();
        saveLocaltarget();
        });
    }
    
    saveObjetoUnity()
    {
        if (vista.objetoUnity == null)
            return null;
                    
        return jsonRequestDecoded
        (
            Resp,
            Method.PUT,
            'private/objetounity',
            vista.objetoUnity
        )
        .then((Resp resp){
        
        if (resp.failed)
            print (resp.error);
        });
    }
    
    saveLocaltarget ()
    {
        if (vista.localTarget == null)
            return;
        
        saveInCollection
        (
            Col.localTarget,
            vista.localTarget
        )
        .then((Resp resp){
        
        if (resp.failed)
            print (resp.error);
        
        });
    }
    
    
    seleccionarTipoVista (TipoDeVista tipo)
    {
        vista.type__ = tipo.type__;
        setIcono();
        print ("TYPE: ${vista.type__}");
        tituloVista = tipo.descripcion;
        switch(vista.type__){
            case 'ConstruccionRAJS, Assembly-CSharp':
                vista
                    ..muebles = []
                    ..cuartos = [];
                
                newFromCollection
                (
                    'objetounity',
                    ObjetoUnitySendResp
                )
                .then((ObjetoUnitySendResp objResp){
                
                if (objResp.success)
                {
                    vista.objetoUnity = objResp.obj;
                    vista.objetoUnityId = vista.objetoUnity.id;
                }
                else
                    print ('Failed to load new ObjetoUnity: ${objResp.error}');
                
                
                return newFromCollection
                (
                    Col.localTarget,
                    LocalImageTargetSendResp
                )
                .then((LocalImageTargetSendResp targetResp){
                
                if (targetResp.success)
                {
                    vista.localTarget = targetResp.obj;
                    vista.localTargetId = vista.localTarget.id;
                    
                    print (vista.localTarget);
                }
                else
                    print ('Failed to load new LocalTarget: ${targetResp.error}');
                
                });
                });
                break;
            case 'InfoContactoJS, Assembly-CSharp':
                vista
                    ..elementosContacto = []
                    ..elementosInfo = [];
                break;
            case 'MultimediaJS, Assembly-CShar':
                break;
            case 'MapaConstruccionJS, Assembly-CSharp':
                break;
            default:
                break;
                
        }
    }
    
    seleccionarTipoElemento (dynamic tipo, dynamic elem)
    {
        elem.type__ = tipo.type__;
    } 
    
    
    String icono = '';
    void setIcono ()
    {
        switch(vista.type__){
            case 'ConstruccionRAJS, Assembly-CSharp':
                icono = "3D";
                break;
            case 'InfoContactoJS, Assembly-CSharp':
                icono = "info";
                break;
            case 'MultimediaJS, Assembly-CShar':
                icono = "Galeria";
                break;
            case 'MapaConstruccionJS, Assembly-CSharp':
                icono = "Ubicacion";
                break;
            default:
                icono= "missing_image";
                break;
                
        }
        
        vista.icon.web = false;
        vista.icon.path = "HG/Materials/App/$icono";
        urlIcono = 'images/webapp/${icono}.png';
    }
    String urlIcono = '';
    
        
    void NuevoMueble ()
    {
        if (vista.muebles == null)
            vista.muebles = [];
        vista.muebles.add(new ElementoConstruccion());
        
    }
    
    void NuevoCuarto ()
    {
        if (vista.cuartos == null)
                    vista.cuartos = [];
        vista.cuartos.add(new ElementoConstruccion());
        
    }
    
    void EliminarElemento (dynamic elem, List<dynamic> listElem)
    {
        listElem.remove(elem);
    }
    

    
    guardarTargetId (String s){
        vista.objetoUnityId = s;
    }
    
    guardarImagenElemento(String s, elemento){
        elemento.imageId = s;
    }
    
    guardarUrlInfo(String s, info){
        info.path = s;
    }
    
    guardarUrlTextura(String s, textura){
        textura.urlTextura = s;
    }
    
    upload (dom.MouseEvent event, String urlObjeto, Function guardar, [dynamic elemento])
    {
        String url = 'private/file';
        String method;
        
        if(urlObjeto == null || urlObjeto == ""){
            method = Method.POST;
            print("no existe, new");
        }
        else
        {   
            var id = urlObjeto.split('/').last;
            url += "/${id}";
            method = Method.PUT;
            print("actualizo");
        }   
    
        dom.FormElement form = getFormElement (event);
                    
        formRequestDecoded (IdResp, method, url, form)
        
        .then(doIfSuccess((IdResp resp)
        {   
            print (resp.success);
            guardar('public/file/${resp.id}', elemento);
            return saveInCollection('vista', vista);
        }))
        
        .then(doIfSuccess((Resp resp)
        {
            dom.window.location.reload(); 
        }));
    }
    
    uploadElementoConstruccion (dom.MouseEvent event, ElementoConstruccion elemento)
    {
        dom.FormElement form = getFormElement (event);
        
        IdResp idResp;
        
        new Future((){
        
        if (notNullOrEmpty (elemento.imageId))
        {
            formRequestDecoded
            (
                IdResp, 
                Method.PUT,
                'private/file/${elemento.imageId}',
                form
            )
            .then((IdResp _idResp){
                                    
            idResp = _idResp;  
            
            });
        }
        else
        {
            formRequestDecoded
            (
                IdResp, 
                Method.POST,
                'private/file',
                form
            )
            .then((IdResp _idResp){
                        
            idResp = _idResp;  
            
            });
        }
        
        }).then((_){
        
        if (! idResp.success)
        {
            print (idResp.error);
            return null;
        }
        
        elemento.imageId = idResp.id;
        
        return saveAndStay();
        
        });
    }
    
    uploadObjetoUnityUserFile (dom.MouseEvent event)
    {
        dom.FormElement form = getFormElement (event);
        
        return new Future ((){
        
        if (notNullOrEmpty (vista.objetoUnityId))
        {
            return formRequestDecoded
            (
                IdResp,
                Method.PUT,
                "private/objetounity/${vista.objetoUnityId}/userfile",
                form
            )
            .then((IdResp resp){
            
            if (! resp.success)
            {
                print ("Upload Failed: ${resp.error}");
            }
            
            vista.objetoUnity.userFileId = resp.id;
            
            });
        }
        else
        {
            print ("Upload Failed: Null or Empty vista.objetoUnityId}");
        }
        
        });
    }
    
    uploadLocalTargetImageFile (dom.MouseEvent event)
    {
        dom.FormElement form = getFormElement (event);
        
        return new Future ((){
        
        if (vista.localTarget != null)
        {
            return formRequestDecoded
            (
                IdResp,
                Method.PUT,
                "private/${Col.localTarget}/${vista.localTarget.id}/userfile",
                form
            )
            .then((IdResp resp){
    
            if (! resp.success)
            {
                print ("Upload Failed: ${resp.error}");
            }
            
            vista.localTarget.imageId = resp.id;
            
            });
        }
        else
        {
            print ("Upload Failed: Null or Empty vista.localTargetId}");
        }
          
        });
    }
    
    /*Función para subir los archivos de Elementos Info en las vistas*/
    uploadElementosInfoImageFile (dom.MouseEvent event, ElementoInfo elementoInfo) 
        {
            dom.FormElement form = getFormElement (event);
            IdResp idResp;
            
            new Future ((){
            
            if (notNullOrEmpty (elementoInfo.imageId))
            {
                return formRequestDecoded
                (
                    IdResp,
                    Method.PUT,
                    "private/file/${elementoInfo.imageId}",
                    form
                )
                .then((IdResp _idResp){
                
                idResp = _idResp;
                    
                });
            }
            else
            {
                return formRequestDecoded
                (
                    IdResp,
                    Method.POST,
                    "private/file",
                    form
                )
                .then((IdResp _idResp){
                                
                idResp = _idResp;
                    
                });
            }
            })
            .then((_){
            
            if (idResp.failed)
            {
                print ("Upload Failed: ${idResp.error}");
                return;
            }
            elementoInfo.imageId = idResp.id;
            
            });
            
        }
}


class TipoDeVista
{
    final String nombre;
    final String descripcion;
    final String type__;
    
    const TipoDeVista (this.type__, this.nombre, this.descripcion);
}

class TipoElementoContacto
{
    final String nombre;
    final String descripcion;
    final String type__;
    
    const TipoElementoContacto (this.type__, this.nombre, this.descripcion);
}

class TipoElementoInfo
{
    final String nombre;
    final String descripcion;
    final String type__;
    
    const TipoElementoInfo (this.type__, this.nombre, this.descripcion);
}
