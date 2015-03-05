part of aristadart.client;

@Component
(
    selector : 'dummy',
    templateUrl: 'components/widgets/dummy/dummy.html',
    exportExpressions: const ["test"],
    useShadowDom: false
)
class Dummy
{
    static List<String> _mensajes = [];
    
    static add (String s)
    {
        _mensajes.add(s);
        
        new Future.delayed(new Duration(seconds: 3)).then((_)
        {
        print (s);
        _mensajes.remove(s);
        });
    }
    
    List<String> get ms => _mensajes;
    
    Dummy ()
    {
        
    }
    
}