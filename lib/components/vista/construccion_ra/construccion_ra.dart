part of aristadart.client;

@Component
(
    selector : "vista",
    templateUrl: 'components/vista/construccion_ra/construccion_ra.html',
    useShadowDom: false
)
class VistaConstruccionRA
{
    ConstruccionRA vista;
    
    VistaConstruccionRA ()
    {
        vista = VistaVista.vistaActual as ConstruccionRA;
    }
}