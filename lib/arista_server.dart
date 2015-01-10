library arista_server;

import 'dart:io';
import 'arista.dart';
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper_mongo/manager.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone/query_map.dart';
import 'package:redstone_mapper/plugin.dart';
import 'utils.dart';
import 'authorization.dart';
import 'package:fp/fp.dart' as F;

part 'services/user_services.dart';
part 'services/evento_services.dart';

ObjectId StringToId (String id) => new ObjectId.fromHexString(id);

HttpSession get session => app.request.session;