part of aristadart.client;

@Component
(
    selector : "titulo-dinamico",
    templateUrl: 'components/widgets/titulo_dinamico/titulo_dinamico.html',
    useShadowDom: false
)
class TituloDinamico
{
    @NgTwoWay('editar')
    bool editar= false;
    
    @NgTwoWay('contenido')
    String contenido ='';
    
    @NgAttr('tipoInput')
    String tipoInput;
    
    @NgAttr('label')
    String label;
    
    TituloDinamico(){
        
    }
}