import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/mapper_factory.dart';
import 'package:aristadart/arista_client.dart';
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



class MyAppModule extends Module
{
    MyAppModule()
    {
        bind (Login);
        bind (Home);
        bind (EventoVista);
        bind(RouteInitializerFn, toValue: recipeBookRouteInitializer);
        bind(NgRoutingUsePushState, toValue: new NgRoutingUsePushState.value(false));
    }
}

class ListInt
{
    @Field() List<int> list;
}

void main()
{
    bootstrapMapper();


    applicationFactory()
        .addModule(new MyAppModule())
        .run();
    
    
}
