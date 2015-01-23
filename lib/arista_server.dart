library arista_server;

import 'dart:io';
import 'dart:convert' as conv;  
import 'arista.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper_mongo/manager.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone/query_map.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone/server.dart';
import 'utils.dart';
import 'authorization.dart';
import 'package:fp/fp.dart' as F;

part 'services/user_services.dart';
part 'services/evento_services.dart';
part 'services/vista_services.dart';
part 'services/general_services.dart';
part 'services/file_services.dart';
part 'services/test_services.dart';
part 'services/vuforia_services.dart';

ObjectId StringToId (String id) => new ObjectId.fromHexString(id);

HttpSession get session => app.request.session;

const String ADMIN = "ADMIN";

class Col
{
    static String user = 'user';
    static String evento = 'evento';
    static String vista = 'vista';
    static String recoTarget = 'recoTarget';
}

Future<List<dynamic>> deleteFiles (GridFS fs, dynamic fileSelector)
{
    return fs.files.find (fileSelector).toList().then((List<Map> list)
    {
        return list.map(F.getByKey('_id')).toList();
    })
    .then((List list)
    {
        var removeFiles = fs.files.remove(where.oneFrom('_id', list));
        var removeChunks = fs.chunks.remove(where.oneFrom('files_id', list));
        
        return Future.wait([removeChunks, removeFiles]);
    });
        
}

Stream<List<int>> getData (GridOut gridOut)
{
    
    
    StreamController<List<int>> controller = new StreamController<List<int>>();
    var n = 0;
          
    gridOut.fs.chunks.find(where.eq("files_id", gridOut.id).sortBy('n'))
    .forEach((Map chunk)
    {
        BsonBinary data = chunk["data"];
        controller.add (data.byteList);
        n++;
    })
    .then((_)
    {
        print ("$n Chunks!");
        controller.close();
    });
    
    return controller.stream;
}

Function bytesToJSON = F.compose([conv.JSON.decode, conv.UTF8.decode]);