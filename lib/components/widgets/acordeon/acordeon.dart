part of aristadart.client;

@Component
(
    selector : "acordeon",
    templateUrl: 'components/widgets/acordeon/acordeon.html',
    useShadowDom: false
)
class Acordeon
{
    @NgTwoWay('mostrarContenido')
    bool mostrarContenido =false;
    
    @NgAttr('titulo')
    String titulo;
    
    Acordeon(){
        
    }
}