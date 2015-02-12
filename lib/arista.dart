library arista;

import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper_mongo/metadata.dart';
import 'package:redstone/query_map.dart';
import 'dart:convert';
import 'dart:async';
import 'package:fp/fp.dart' as F;

part 'models/evento.dart';
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
part 'models/panel_info.dart';
part 'models/validation_rules/truth.dart';

String get localHost => "http://localhost:9090/";

class ListInt
{
    @Field() List<int> list;
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

QueryMap NewQueryMap () => new QueryMap(new Map());
QueryMap MapToQueryMap (Map map) => new QueryMap(map);

class Resp
{
    @Field() bool get success => ! notNullOrEmpty(error);
    @Field() String error;
    
    Resp();
    
    Resp.failed (this.error);
}

class VistasResp extends Resp
{
    @Field() List<Vista> vistas = [];
}

class VistaResp extends Resp
{
    @Field() Vista vista;
}

class VistaExportableResp extends Resp
{
    @Field() VistaExportable vista;
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

class UserAdminResp extends Resp
{
    @Field() UserAdmin user;
}

class EventoExportableResp extends Resp
{
    @Field() EventoExportable evento;
}

class UrlResp extends Resp
{
    @Field() String url;
}

class ObjetoUnityResp extends Resp
{
    @Field() ObjetoUnity obj;
}

class ObjetoUnitySendResp extends Resp
{
    @Field() ObjetoUnitySend obj;
}

class LocalImageTargetSendResp extends Resp
{
    @Field() LocalImageTargetSend obj;
}

class ObjetoUnitySendListResp extends Resp
{
    @Field() List<ObjetoUnitySend> objs;
}

class LocalTargetSendListResp extends Resp
{
    @Field() List<LocalImageTargetSend> objs;
}

class RecoTargetResp extends Resp
{
    @Field() CloudImageTarget recoTarget;
}

class MapResp extends Resp
{
    @Field() Map map;
}

List flatten (List<List> list) => list.expand(F.identity).toList();

abstract class ContType
{
    static String applicationJson = "application/json";
}

abstract class Method
{
    static String POST = "POST";
    static String PUT = "PUT";
    static String GET = "GET";
    static String DELETE = "DELETE";
}

bool notNullOrEmpty (String s) => ! (s == null || s == '');