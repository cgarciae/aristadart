library aristaweb;

import 'package:gcloud/db.dart';
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:appengine/appengine.dart';
import 'package:fp/fp.dart';
import 'package:restonetest/general/aristageneral.dart';

part 'models/texture_gui.dart';
part 'models/evento.dart';
part 'models/view.dart';
part 'models/elemento_construccion.dart';
part 'models/experiencia.dart';

DatastoreDB get db => context.services.db;

abstract class IBuild
{
    Future Build ([_]);
}

abstract class SuperModel extends Model
{

    Future<SuperModel> Put ([dynamic _])
    {
        if (parentKey == null)
            parentKey = db.emptyKey.append(runtimeType, id: 1);

        return db.commit(inserts: [this]).then(Return);
    }
    
    
    Future<SuperModel> Delete ([dynamic _])
    {
        return db.commit(deletes: [key]).then(Return);
    }
    
    static Future<Model> Get (Key key)
    {
        return db.lookup([key]).then (first);
    }
    
    Future<List<Model>> All ([dynamic _]) => db.query(this.runtimeType).run().toList();
    
    Future<SuperModel> Return ([dynamic _]) => new Future.value(this);
}

class SuperKey extends Key
{
    SuperKey(Key parent, Type type, Object id) : super (parent, type, id) {}

    SuperKey.emptyKey(Partition partition) : super.emptyKey(partition) {}
    
    static SuperKey convert (Key normalKey)
    {
        return new SuperKey(normalKey.parent, normalKey.type, normalKey.id);
    }
    
    Future<Model> Get ()
    {
        return db .lookup ([this]) .then (first);
    }
}

abstract class Help
{
    
    static Future<dynamic> ClearAll (List<Model> list)
    {
        var del = list.map((t) => t.key);
        return db.commit(deletes: del);
    }
    
    static Future<List<Model>> All (Type kind) => db.query (kind).run().toList();
    static Function AllF (Type kind) => ([dynamic o]) => All (kind);

    static Future<dynamic> ClearAllOfKind (Type kind) => All (kind).then (ClearAll);
    static Function ClearAllOfKindF (Type kind) => ([dynamic o]) => ClearAllOfKind(kind);
    
    static Future<Model> FindId (Type kind, Object id) 
    {
        return new SuperKey 
        (
            db.emptyKey.append(kind, id: 1),
            kind,
            id
        )
        .Get();
    }
    
    static Future<SuperModel> Build (dynamic model) => model.Build();
}



class TC
{   
    @Field() String field;
}

@Kind()
class TS extends SuperModel with TC
{
    @StringProperty() String field;
    
    TS ();
}

@Kind()
class G extends Model
{
    @ListProperty(const ModelKeyProperty())
    List<Key> keySS = [];
}