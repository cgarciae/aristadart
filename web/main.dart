import 'package:angular/angular.dart';
import 'package:angular/routing/module.dart';
import 'package:angular/application_factory.dart';
import 'package:logging/logging.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/mapper_factory.dart';
import 'package:aristadart/arista_client.dart';
import 'package:aristadart/arista.dart';
import 'dart:html' as dom;
import 'package:redstone/query_map.dart';
import  'dart:html';

@MirrorsUsed(targets: const[
  'angular',
  'angular.core',
  'angular.core.dom',
  'angular.filter',
  'angular.perf',
  'angular.directive',
  'angular.routing',
  'angular.core.parser',
  'NodeTreeSanitizer'
  ],
  override: '*')
import 'dart:mirrors';

@Injectable()
class MainController 
{
    Router router;
    
    MainController (this.router);
    
    logout ()
    {
        requestDecoded(Resp, Method.GET,'user/logout').then((Resp resp)
        {
            if (resp.success)
            {
                storage.remove('id');
                
                router.go('login', {});
            }
            else
            {
                dom.window.alert("Logout Failed");
            }
        });
    }
    
    bool get LoggedIn => loggedIn;
}


class MyAppModule extends Module
{
    MyAppModule()
    {
        bind (Login);
        bind (Home);
        bind (EventoVista);
        bind (VistaVista);
        bind(NuevoUsuario);
        bind (RouteInitializerFn, toValue: recipeBookRouteInitializer);
        bind (NgRoutingUsePushState, toValue: new NgRoutingUsePushState.value(false));
    }
}

class ListInt
{
    @Field() List<int> list;
}

void main()
{
    bootstrapMapper();

    Logger.root.level = Level.FINEST;
    Logger.root.onRecord.listen((LogRecord r) { print(r.message); });

    applicationFactory()
        .addModule(new MyAppModule())
        .rootContextType(MainController)
        .run();
    
    
}
