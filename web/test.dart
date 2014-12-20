import 'package:redstone_mapper/mapper_factory.dart';
import 'package:redstone_mapper/mapper.dart';





void main()
{
    bootstrapMapper();

    List<int> list = new List<int> ();
    
    print (decodeJson('[4925812092436480,4925812092436481]', list.runtimeType));

    
}
