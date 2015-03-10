part of aristadart.server;


@app.Group('/${Col.localTarget}')
@Catch()
class LocalImageTargetServices extends MongoDbService<LocalImageTarget>
{
    LocalImageTargetServices() : super (Col.localTarget);
    
    @app.DefaultRoute (methods: const [app.POST])
    @Private()
    @Encode()
    Future<ObjetoUnity> New () async
    {
        LocalImageTarget localTarget = new LocalImageTarget()
            ..name = "Nuevo Target"
            ..version = 0
            ..updatePending = false
            ..datUpdated = false
            ..xmlUpdated = false
            ..id = newId()     
            ..owner = (new User()
                ..id = userId);
        
        await insert(localTarget);
        
        return localTarget;
    }
    
    @app.Route ('/:id', methods: const [app.GET])
    @Encode()
    Future<LocalImageTarget> Get (String id) async
    {
        LocalImageTarget localTarget = await findOne
        (
            where.id(StringToId(id))
        );
        
        if (localTarget == null)
            throw new app.ErrorResponse (400, "Local Image Target no encontrado");
        
        return localTarget;
    }
    
    @app.Route ('/:id', methods: const [app.PUT])
    @Private()
    @Encode()
    Future<LocalImageTarget> Update (String id, @Decode() LocalImageTarget delta) async
    {
        await db.update
        (
            collectionName,
            where.id(StringToId(id)),
            getModifierBuilder(delta)
        );
        
        return Get(id);
    }
    
    @app.Route ('/:id', methods: const [app.DELETE])
    @Private()
    @Encode()
    Future<DbObj> Delete (String id) async
    {
        await remove
        (
            where.id(StringToId(id))
        );
        
        return new DbObj()
            ..id = id;
    }
    
    @app.Route ('/:id/image', methods: const [app.POST, app.PUT], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<LocalImageTarget> NewOrUpdateUserFile (
                                    String id, 
                                    @app.Body(app.FORM) QueryMap form, 
                                    @Decode(fromQueryParams: true) FileDb metadata) async
    {
        //Variables
        FileDb userFile;
        
        //Obtener objeto unity
        LocalImageTarget obj = await Get (id);
        
        //Revisar si userFile existe
        if (obj.image != null)
        {
            //Update
            userFile = await new FileServices().Update (obj.image.id, form);
        }
        else
        {
            //New
            userFile = await new FileServices().NewOrUpdate(form, metadata);
        }
        
        //Crear cambios
        LocalImageTarget delta = new LocalImageTarget()
            ..updatePending = true
            ..image = (new FileDb()
                ..id = userFile.id);
        
        //Guardar cambios
        await Update (id, delta);
       
        
        return Get(id);
    }
    
    @app.Route ('/:id/publish', methods: const [app.PUT])
    @Private()
    @Encode()
    Future<LocalImageTarget> Publish (String id) async
    {
        //Obtener el objeto
        LocalImageTarget obj = await Get (id);
        
        //Avisar error si el objeto no esta propiamente actualizado
        if (! (obj.active && obj.updated))
            throw new app.ErrorResponse (400, "No se puede publicar LocalImageTarget. Estado Actual: ${encodeJson(obj)}");
        
        //Crear cambios
        LocalImageTarget delta = new LocalImageTarget()
            ..version = obj.version + 1
            ..updatePending = false
            ..datUpdated = false
            ..xmlUpdated = false;
        
        //Guardar
        await db.update
        (
            collectionName,
            where.id(StringToId(id)),
            getModifierBuilder(delta)
        );
        
        //Retornar objeto modificado
        return Get (id);
    }
    
    @app.Route ('/:id/files', methods: const [app.PUT], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<LocalImageTarget> UpdateFiles (String id,
                                @app.Body(app.FORM) QueryMap form) async
    {
        //Definir cambio
        LocalImageTarget delta = new LocalImageTarget();
        
        //Objeto actual
        LocalImageTarget obj = await Get (id);
        
        obj.owner = await new UserServives().GetGeneric(obj.owner.id);
        
        //Si se envio archivo para 'xml'
        if (form.xml != null && form.xml is app.HttpBodyFileUpload)
        {
            //Actualizar FileDb obj.ios
            FileDb newFile = await actualizarArchivos
            (
                obj.xml, LocalTargetFileType.xml, form.xml, obj.owner.id
            );
            
            //Guardar unicamente el [id] en delta
            delta
            ..xml = (new FileDb()
                ..id = newFile.id)
            ..xmlUpdated = true;
        }
        
        //Si se envio archivo para 'dat'
        if (form.dat != null && form.dat is app.HttpBodyFileUpload)
        {
            //Actualizar FileDb obj.android
            FileDb newFile = await actualizarArchivos
            (
                obj.dat, LocalTargetFileType.dat, form.dat, obj.owner.id
            );
          
            //Guardar unicamente el [id] en delta
            delta
            ..dat = (new FileDb()
                ..id = newFile.id)
            ..datUpdated = true;
        }
        
        //Guardar cambios
        return Update(id, delta);
    }
    
    @app.Route ('/find', methods: const [app.GET])
    @Private(ADMIN)
    @Encode()
    Future<ListLocalImageTargetResp> Find (@app.QueryParam() bool updatePending,
           @app.QueryParam() String userId) async
    {
        //Definir query object
        Map query = {};
        
        //Buscar usuario
        if  (userId != null)
        query["owner._id"] = StringToId (userId);
        
        //Agregar pending
        if (updatePending != null)
        query["updatePending"] = updatePending;
        
        //Buscar lista
        List<LocalImageTarget> list = await find (query);
        
        //Responder
        return new ListLocalImageTargetResp()
        ..list = list;
    }

    @app.Route ('/all', methods: const [app.GET])
    @Encode()
    Future<ListLocalImageTargetResp> All (@app.QueryParam() bool updatePending) async
    {
        return Find (updatePending, userId);
    }
    
    @app.Route ('/deleteAll', methods: const [app.GET])
    @Private(ADMIN)
    @Encode()
    Future<ListLocalImageTargetResp> DeleteAll (@app.QueryParam() bool updatePending,
                                           @app.QueryParam() String userId) async
    {
        //Definir query object
        Map query = {};
                
        //Buscar usuario
        if  (userId != null)
            query["owner._id"] = StringToId (userId);
        
        //Agregar pending
        if (updatePending != null)
            query["updatePending"] = updatePending;
        
        //Eliminar lista
        await remove (query);
        
        //Responder
        return Find(updatePending, userId);
    }
 
    Future<FileDb> actualizarArchivos (FileDb modelo, 
                                        String extension, 
                                        app.HttpBodyFileUpload fileUpload,
                                        String ownerId) async
    {
        //Definir nuevo form
          Map newForm = {extension : fileUpload};
          
          //Resultado
          FileDb file;
          
          print ("Actualizando $extension");
          
          //Si ios ya existe
          if (modelo != null && modelo.id != null)
          {
              print ("Modelo Existe en $extension");
              file = await new FileServices().Update
              (
                  modelo.id,
                  newForm,
                  ownerId: ownerId
              );
          }
          else
          {
              var metadata = new FileDb()
                ..type = extension;
              
              print ("Modelo no existe en $extension");
              file = await new FileServices().NewOrUpdate
              (
                  newForm,
                  metadata,
                  ownerId: ownerId
              );
          }
          
          print ("Finalizo Actualizacion en $extension, el archivo es ${encodeJson(file)}");
          
          return file;
    }
}