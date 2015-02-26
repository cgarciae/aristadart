part of aristadart.client;

@Component
(
    selector : 'loader',
    templateUrl: 'components/widgets/loader/loader.html',
    useShadowDom: false
)
class AristaLoader
{
    @NgOneWay('loading')
    bool loading;
    
}