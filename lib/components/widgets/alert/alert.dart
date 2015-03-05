part of aristadart.client;


@Component
(
    selector : 'arista-alert',
    templateUrl: 'components/widgets/alert/alert.html',
    exportExpressions: const ['alerts', 'type', 'msg', 'addAlert', 'closeAlert'],
    useShadowDom: false
)
class AristaAlert 
{
    @NgTwoWay("alerts")
    static List<Map<String,String>> alerts = [];
    
    @NgTwoWay("show")
    bool show = false;

    AristaAlert() {
      print("*****AlertDemoComponent");
      alerts.clear();
    }

    void addAlert(Map<String,String> params) {
      alerts.add(params);
      show = true;
    }


   
}