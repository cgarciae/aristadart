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
    Vista vista = new Vista()
       ..muebles = []
       ..cuartos = []
       ..elementosContacto = []
       ..elementosInfo = [];
    String eventoID;
    
    ElementoInfo infoElem = new ElementoInfo();
    ElementoContacto contacto = new ElementoContacto();
    
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
    }
    
    seleccionarTipoElementoInfo (ElementoInfo tipo)
    {
        infoElem.type__ = tipo.type__;
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
    
    void EliminarElemento (ElementoConstruccion elem, List<ElementoConstruccion> listElem)
    {
        listElem.remove(elem);        
        
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
