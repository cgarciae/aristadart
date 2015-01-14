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
                'Vista con informacion general y opciones de contacto')
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

    
    
    seleccionarTipo (TipoDeVista tipo)
    {
        vista.type__ = tipo.type__;
    }
    
}

class TipoDeVista
{
    final String nombre;
    final String descripcion;
    final String type__;
    
    const TipoDeVista (this.type__, this.nombre, this.descripcion);
}
