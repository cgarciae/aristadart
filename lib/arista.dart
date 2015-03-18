library aristadart.general;

import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper_mongo/metadata.dart';
import 'package:redstone/query_map.dart';
import 'dart:convert';

part 'models/evento.dart';
part 'models/vuforia_target.dart';
part 'models/texture_gui.dart';
part 'models/experiencia.dart';
part 'models/elemento_contacto.dart';
part 'models/elemento_info.dart';
part 'models/vista.dart';
part 'models/local_image_target.dart';
part 'models/cloud_image_target.dart';
part 'models/elemento_construccion.dart';
part 'models/objeto_unity.dart';
part 'models/user.dart';
part 'models/file.dart';
part 'models/validation_rules/truth.dart';

const int tipoBuild = TipoBuild.jsTesting;

int get port => 9090;

String get staticFolder {
    switch (tipoBuild)
    {
        case TipoBuild.desarrollo:
            return "../web";
        case TipoBuild.jsTesting:
            return "../build/web";
        case TipoBuild.dockerTesting:
        case TipoBuild.deploy:
            return "build/web";
    }
}

String get partialHost {
    switch (tipoBuild)
    {
        case TipoBuild.desarrollo:
        case TipoBuild.jsTesting:
        case TipoBuild.dockerTesting:
            return "localhost:9090";
        case TipoBuild.deploy:
            return "104.131.109.228";
    }
}



String get localHost => "http://${partialHost}/";

String get partialDBHost {
    switch (tipoBuild)
    {
        case TipoBuild.desarrollo:
        case TipoBuild.jsTesting:
            return "192.168.59.103:8095";
        case TipoBuild.dockerTesting:
        case TipoBuild.deploy:
            return "db";
    }
}

class TipoBuild
{
    static const int desarrollo =  0;
    static const int jsTesting =  1;
    static const int dockerTesting =  2;
    static const int deploy =  3;
}

Function decodeTo (Type type)
{
    return (String json)
    {
        return decodeJson(json, type);
    };
}

dynamic MapToObject (Type type, Map map)
{
    return decodeJson(JSON.encode(map), type);
}

Map ObjectToMap (dynamic obj)
{
    return JSON.decode (encodeJson (obj));
}

Map addOrSet (Map headers, Map additions)
{
    
    if (headers != null)
        headers.addAll (additions);
    else
        headers = additions;
    
    
    return headers;
}

Map maybeAdd (Map map, String field, Object value)
{
    
    if (value != null)
        map [field] = value;
    
    return map;
}

QueryMap NewQueryMap () => new QueryMap(new Map());
QueryMap MapToQueryMap (Map map) => new QueryMap(map);

dynamic Cast (Type type, Object obj) => decode (encode(obj), type);
dynamic Clone (Object obj) => decode (encode(obj), obj.runtimeType);

class Resp
{
    bool get success => nullOrEmpty(error);
    bool get failed => ! success;
    
    @Field() String error;
    @Field() int errCode;
}

class DbObj extends Resp
{
    @Id() String id;
}

class Ref extends DbObj
{
    String get href => "IMPLEMENTATION MISSING";
}

class ListEventoResp extends Resp
{
    @Field() List<Evento> eventos;
}

class ListVistaResp extends Resp
{
    @Field() List<Vista> vistas;
}

class VistasResp extends Resp
{
    @Field() List<Vista> vistas = [];
}

class VistaResp extends Resp
{
    @Field() Vista vista;
}

class IdResp extends Resp
{
    @Field() String id;
}

class BoolResp extends Resp
{
    @Field() bool value;
}

class UserResp extends Resp
{
    @Field() User user;
}

class UrlResp extends Resp
{
    @Field() String url;
}

class ObjetoUnityResp extends Resp
{
    @Field() ObjetoUnity obj;
}

List flatten (List<List> list) => list.expand((x) => x).toList();

abstract class Header
{
    static const String contentType = 'Content-Type';
    static const String authorization = 'Authorization';
}

abstract class ContType
{
    static const String applicationJson = r"application/json";
    static const String multipart = "multipart";
    static const String imagePng = r"image/png";
}

abstract class Method
{
    static final String POST = "POST";
    static final String PUT = "PUT";
    static final String GET = "GET";
    static final String DELETE = "DELETE";
}

abstract class Col
{
    static const String user = 'user';
    static const String evento = 'evento';
    static const String vista = 'vista';
    static const String cloudTarget = 'cloudTarget';
    static const String objetoUnity = 'objetoUnity';
    static const String localTarget = 'localTarget';
}

abstract class ErrCode
{
    static final int NOTFOUND = 1;
}

bool notNullOrEmpty (String s) => ! (s == null || s == '');
bool nullOrEmpty (String s) => ! notNullOrEmpty (s);

abstract class IconDir
{
    static const String missingImage = "images/webapp/missing_image.png";
    static const String icon3D = "images/webapp/3D.png";
}
