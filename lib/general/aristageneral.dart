library aristageneral;

import 'package:redstone_mapper/mapper.dart';
import 'dart:async';

part 'models/evento.dart';
part 'models/texture_gui.dart';
part 'models/experiencia.dart';
part 'models/view.dart';
part 'models/arista_image_target.dart';
part 'models/elemento_construccion.dart';
part 'models/objeto_unity.dart';

String get localHost => "http://localhost:8080";

class ListInt
{
    @Field() List<int> list;
}