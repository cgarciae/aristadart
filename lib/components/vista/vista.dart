part of arista_client;

@Component
(
    selector : "vista",
    templateUrl: 'components/vista/vista.html',
    useShadowDom: false
)
class VistaVista
{
    Router router;
    Vista vista = new Vista();
    String eventoID;
    
    List<TipoDeVista> tiposDeVista = const 
    [
        const TipoDeVista (
                'ConstruccionRAJS, Assembly-CSharp', 
                'Construccion RA', 
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
        var id = routeProvider.parameters['vistaID'];
        eventoID = routeProvider.parameters['eventoID'];
        
        routeProvider.parameters.keys.forEach(print);
        
        if (id == null)
        {
            print ('NUEVA VISTA');
            //Crear nuevo evento
            newFromCollection ('vista').then (doIfSuccess ((IdResp res)
            {
                vista.id = res.id;
            }));
        }
        else
        {
            print ('CARGAR VISTA');
            
            //Cargar vista
            getFromCollection (VistaResp, 'vista', id).then (doIfSuccess ((VistaResp resp)
            {
                vista = resp.vista;
                icono = vista.icon.urlTextura.split(r'/').last;
            }));
        }
    }
    
    save ()
    {
        saveInCollection ('vista', vista)
        .then(doIfSuccess((Resp resp)
        {
            router.go('evento', {'eventoID' : eventoID});
        }));
    }

    
    
    seleccionarTipoVista (TipoDeVista tipo)
    {
        vista.type__ = tipo.type__;
        switch(vista.type__){
            case 'ConstruccionRAJS, Assembly-CSharp':
                vista
                    ..muebles = []
                    ..cuartos = []
                    ..modelo = new ObjetoUnity()
                    ..target = new AristaImageTarget();
                break;
            case 'InfoContactoJS, Assembly-CSharp':
                vista
                    ..elementosContacto = []
                    ..elementosInfo = [];
                break;
            default:
                break;
                
        }
    }
    
    seleccionarTipoElemento (dynamic tipo, dynamic elem)
    {
        elem.type__ = tipo.type__;
    } 
    
    String _icono = '';
    void set icono (String opcion)
    {
        _icono = opcion;
        vista.icon.urlTextura = "HG/Materials/App/$opcion";
        urlIcono = 'images/webapp/${opcion}.png';
    }
    String get icono => _icono;
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
    
    guardarUrlObjeto(String s){
        vista.modelo.url_objeto = s;
    }
    
    upload (dom.MouseEvent event, String urlObjeto, Function guardar)
    {
        String url = '';
        
        if(urlObjeto == null || urlObjeto == ""){
            
            url = 'private/new/file';
            print("no existe, new");
        }else{
            
            url = "private/update/file/${urlObjeto.split('/').last}";
            print("actualizo");
        }   
    
        dom.FormElement form = (event.target as dom.ButtonElement).parent as dom.FormElement;
                    
        formRequestDecoded(url, form, IdResp).then((IdResp resp)
        {   
            print (resp.success);
            guardar('public/get/file/${resp.id}');
            return saveInCollection('vista', vista);
        }).then((Resp resp)
        {
            if(resp.success)
                dom.window.location.reload(); 
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
