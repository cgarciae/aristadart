import 'package:restonetest/client/aristaclient.dart';
import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/mapper_factory.dart';

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
        bind (EventoComponent);
        bind (AAA);
        bind (BBB);
        bind (CCC);
    }
}

class ListInt
{
    @Field() List<int> list;
}

void main()
{
    bootstrapMapper();

    List<int> list = new List<int> ();
    
    print (decodeJson(r'{"list":[4925812092436480,4925812092436481]}', ListInt).list);

    applicationFactory()
        .addModule(new MyAppModule())
        .run();
    
}
