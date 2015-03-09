part of aristadart.server;


abstract class AristaService<T extends DbObj> extends MongoDbService<T>
{
    AristaService (String collectionName) : super (collectionName);
    
    Future<T> NewGeneric (T obj) async
    {
        await insert (obj);
        
        return obj;
    }
    
    Future<T> GetGeneric (String id, [String errorMsg]) async
    {
        T obj = await findOne
        (
            where.id(StringToId(id)) 
        );
        
        if (obj == null)
            throw new Exception(errorMsg != null ? errorMsg : "$collectionName not found");
        
        return obj;
    }
    
    Future UpdateGeneric (String id, @Decode() T delta) async
    {
        delta.id = null;
        
        await update
        (
            where.id(StringToId(id)),
            delta,
            override: false
        );
    }
    
    Future<DbObj> DeleteGeneric (String id) async
    {
        await remove (where.id (StringToId (id)));
        
        return new DbObj()
            ..id = id;
    }
    
    Future<List<T>> AllGeneric () async
    {
        return find (where.eq ("owner._id", StringToId (userId)));
    }
    
}
