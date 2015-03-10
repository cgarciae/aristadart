library aristadart.main;


import 'package:angular/angular.dart';
import 'package:angular/routing/module.dart';
import 'package:angular/application_factory.dart';
import 'package:logging/logging.dart';


import 'package:redstone_mapper/mapper_factory.dart';
import 'package:aristadart/arista_client.dart';
import 'package:aristadart/arista.dart';
import 'dart:html' as html;


void main()
{
    bootstrapMapper();
    
    Requester.decoded (BoolResp, Method.GET, '/testErro1/${0}').then((BoolResp resp){
        
    print ("Value is ${resp.value}");
    
    }).catchError((e, s){
    html.HttpRequest req = e.target;
        
    print ("Hubo un error");
    print (req.responseText);
    print (s);
    }, test:(e) => e is html.ProgressEvent);
}

printReqError (e, s) => print ("e\ns");
ifProgEvent (e) => e is dom.ProgressEvent;
