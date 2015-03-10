part of aristadart.client;

@Component
(
    selector : "construccion-ra",
    templateUrl: 'components/vista/construccion_ra/construccion_ra.html',
    useShadowDom: false
)
class VistaConstruccionRA
{
    
    ConstruccionRA vista = new ConstruccionRA();
    ClientVistaServices vistaServices;
    Router router;
     
    VistaConstruccionRA (RouteProvider routeProvider, this.router)
    {
        
        vista.id = routeProvider.parameters['vistaID'];
        //eventoId = routeProvider.parameters['eventoID'];
        
        vistaServices = new ClientVistaServices(vista);
        
        vistaServices.Get().then((_vista){
        
        print (vista.runtimeType);
        
        vista = _vista;
        
        }).catchError(printReqError, test: ifProgEvent);
    }
}