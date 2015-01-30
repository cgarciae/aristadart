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
part 'models/arista_image_target.dart';
part 'models/elemento_construccion.dart';
part 'models/objeto_unity.dart';
part 'models/user.dart';
part 'models/panel_info.dart';

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
    @Field() bool success;
    @Field() String error;
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

class UrlResp extends Resp
{
    @Field() String url;
}

class RecoTargetResp extends Resp
{
    @Field() AristaCloudRecoTarget recoTarget;
}

class MapResp extends Resp
{
    @Field() String map;
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
