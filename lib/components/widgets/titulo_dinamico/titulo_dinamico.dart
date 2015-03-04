part of aristadart.client;

@Component
(
    selector : "titulo-dinamico",
    templateUrl: 'components/widgets/titulo_dinamico/titulo_dinamico.html',
    cssUrl: 'components/widgets/titulo_dinamico/titulo_dinamico.css'
)
class TituloDinamico
{
    @NgTwoWay('editar')
    bool editar= false;
    
    @NgTwoWay('contenido')
    String contenido ='';
    
    @NgAttr('label')
    String label;
    
    TituloDinamico(){
        
    }
}