library aristadart.server;

import 'dart:io';
import 'dart:convert' as conv;  
import 'package:aristadart/arista.dart';
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
import 'package:fp/fp.dart' as F;

part 'services/user_services.dart';
part 'services/evento_services.dart';
part 'services/vista_services.dart';
part 'services/general_services.dart';
part 'services/file_services.dart';
part 'services/objeto_unity_services.dart';
part 'services/local_target_services.dart';
part 'services/test_services.dart';
part 'services/vuforia_services.dart';
part 'authorization.dart';

ObjectId StringToId (String id) => new ObjectId.fromHexString(id);

HttpSession get session => app.request.session;
ObjectId get userId => session['id'];

MongoDb get dbConn => app.request.attributes.dbConn;

const String ADMIN = "ADMIN";


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

Map bytesToJSON (List<int> list)
{
    var string = conv.UTF8.decode (list);
    var map = conv.JSON.decode (string);
    
    print (string);
    print (map);
    
    return map;
}

Function ifDidntFail (Function f)
{
    return (resp)
    {
        if (resp is Resp && resp.success == false)
            return resp;
        else
            return f (resp);
    };
}

Function ifNotNull (String failMessage, dynamic f (dynamic))
{
    return (Object obj)
    {
        if (obj == null)
            return new Resp()
                ..error = failMessage;
        
        return f (obj);
    };
}

ModifierBuilder getRefModifierBuilder (Ref obj)
{
    return getModifierBuilder
    (
        obj..error = null
    );
}

ModifierBuilder getModifierBuilder (Object obj)
{
    Map<String, dynamic> map = encode(obj);
    
    print (map);
    
    ModifierBuilder mod = modify;
    
    for (String key in map.keys)
    {
        mod.set(key, map[key]);
    }
    
    print (mod);
    
    return mod;
}
