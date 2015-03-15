part of aristadart.server;


@app.Group('/${Col.objetoUnity}')
@Catch()
class ObjetoUnityServices extends AristaService<ObjetoUnity>
{
    ObjetoUnityServices() : super (Col.objetoUnity);
    
    @app.DefaultRoute (methods: const [app.POST])
    @Private()
    @Encode()
    Future<ObjetoUnity> New () async
    {
        ObjetoUnity obj = new ObjetoUnity()
            ..name = "Nuevo Modelo"
            ..version = 0
            ..public = false
            ..updatePending = false
            ..androidUpdated = false
            ..iosUpdated = false
            ..windowsUpdated = false
            ..osxUpdated= false
            ..id = newId()     
            ..owner = (new User()
                ..id = userId);
        
        return NewGeneric(obj);
    }
    
    @app.Route ('/:id', methods: const [app.GET])
    @Encode()
    Future<ObjetoUnity> Get (String id) async
    {
        return GetGeneric(id);
    }
    
    @app.Route ('/:id', methods: const [app.PUT])
    @Private()
    @Encode()
    Future<ObjetoUnity> Update (String id, @Decode() ObjetoUnity delta) async
    {
        await UpdateGeneric(id, delta);
        
        return Get(id);
    }
    
    @app.Route ('/:id', methods: const [app.DELETE])
    @Private()
    @Encode()
    Future<DbObj> Delete (String id) async
    {
        await DeleteGeneric(id);
    }
    
    @app.Route ('/:id/userFile', methods: const [app.POST, app.PUT], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<ObjetoUnity> NewOrUpdateUserFile (
                                    String id, 
                                    @app.Body(app.FORM) QueryMap form, 
                                    @Decode(fromQueryParams: true) FileDb metadata) async
    {
        //Variables
        FileDb userFile;
        
        //Obtener objeto unity
        ObjetoUnity obj = await Get (id);
        
        //Revisar si userFile existe
        if (obj.userFile != null)
        {
            //Update
            userFile = await new FileServices().Update (obj.userFile.id, form);
        }
        else
        {
            //New
            userFile = await new FileServices().NewOrUpdate(form, metadata);
        }
        
        //Crear cambios
        ObjetoUnity delta = new ObjetoUnity()
            ..updatePending = true
            ..userFile = (new FileDb()
                ..id = userFile.id);
        
        //Guardar cambios
        await Update (id, delta);
       
        
        return Get(id);
    }
    
    @app.Route ('/:id/publish', methods: const [app.PUT])
    @Private()
    @Encode()
    Future<ObjetoUnity> Publish (String id) async
    {
        //Obtener el objeto
        ObjetoUnity obj = await Get (id);
        
        //Avisar error si el objeto no esta propiamente actualizado
        if (! (obj.active && obj.updated))
            throw new app.ErrorResponse (400, "No se puede publicar ObjetoUnity. Estado Actual: ${encodeJson(obj)}");
        
        //Crear cambios
        ObjetoUnity delta = new ObjetoUnity()
            ..version = obj.version + 1
            ..updatePending = false
            ..androidUpdated = false
            ..windowsUpdated = false
            ..iosUpdated = false
            ..osxUpdated = false;
        
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
    
    @app.Route ('/:id/models', methods: const [app.PUT], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<ObjetoUnity> UpdateModels (String id,
                                @app.Body(app.FORM) QueryMap form) async
    {
        //Definir cambio
        ObjetoUnity delta = new ObjetoUnity();
        
        //Objeto actual
        ObjetoUnity obj = await Get (id);
        
        obj.owner = await new UserServives().GetGeneric(obj.owner.id);
        
        //Si se envio archivo para 'ios'
        if (form.ios != null && form.ios is app.HttpBodyFileUpload
            && form.ios.content is List && form.ios.content.isNotEmpty)
        {
            print ("ios");
            print (form.ios);
            print (form.ios.content);
            
            //Actualizar FileDb obj.ios
            FileDb newFile = await ActualizarModelo
            (
                obj.ios, SystemType.ios, form.ios, obj.owner.id
            );
            
            //Guardar unicamente el [id] en delta
            delta
            ..ios = (new FileDb()
                ..id = newFile.id)
            ..iosUpdated = true;
        }
        
        //Si se envio archivo para 'android'
        if (form.android != null && form.android is app.HttpBodyFileUpload
            && form.android.content is List && form.android.content.isNotEmpty)
        {
            print ("android");
            //Actualizar FileDb obj.android
            FileDb newFile = await ActualizarModelo
            (
                obj.android, SystemType.android, form.android, obj.owner.id
            );
          
            //Guardar unicamente el [id] en delta
            delta
            ..android = (new FileDb()
                ..id = newFile.id)
            ..androidUpdated = true;
        }
        
        if (form.windows != null && form.windows is app.HttpBodyFileUpload
            && form.windows.content is List && form.windows.content.isNotEmpty)
        {
            print ("windows");
            //Actualizar FileDb obj.windows
            FileDb newFile = await ActualizarModelo
            (
                obj.windows, SystemType.windows, form.windows, obj.owner.id
            );
          
            //Guardar unicamente el [id] en delta
            delta
            ..windows = (new FileDb()
                ..id = newFile.id)
            ..windowsUpdated = true;
        }
        
        if (form.osx != null && form.osx is app.HttpBodyFileUpload
            && form.osx.content is List && form.osx.content.isNotEmpty)
        {
            print ("osx");
            //Actualizar FileDb obj.osx
            FileDb newFile = await ActualizarModelo
            (
                obj.osx, SystemType.osx, form.osx, obj.owner.id
            );
          
            //Guardar unicamente el [id] en delta
            delta
            ..osx = (new FileDb()
                ..id = newFile.id)
            ..osxUpdated = true;
        }
        
        //Guardar cambios
        return Update (id, delta);
    }
    
    @app.Route ('/find', methods: const [app.GET])
    @Private(ADMIN)
    @Encode()
    Future<List<ObjetoUnity>> Find (
                        @app.QueryParam() bool updatePending,
                        @app.QueryParam() String userId,
                        @app.QueryParam() bool active,
                        @app.QueryParam() bool public,
                        {@app.QueryParam() bool findOwners}) async
    {
        
        print (app.request.requestedUri.toString());
        //Definir query object
        Map query = {};
        
        //Buscar usuario
        if  (userId != null)
        query["owner._id"] = StringToId (userId);
        
        //Agregar pending
        if (updatePending != null)
        query["updatePending"] = updatePending;
        
        //Agregar pending
        if (active != null)
            query["active"] = active;
        
        if (public != null)
            query = {r'$or': [query, {'public' : public}]};
        
        //Buscar lista
        List<ObjetoUnity> list = await find (query);
        
        if (findOwners == true)
        {
            for (ObjetoUnity obj in list)
            {
                obj.owner = await new UserServives().GetGeneric(obj.owner.id);
            }
        }
        
        return list;
    }

    /**
     * Si [public] es un parametro, adicionalmente busca todos los objetos donde
     * [public] es verdadero.
     */
    @app.Route ('/all', methods: const [app.GET])
    @Encode()
    Future<List<ObjetoUnity>> All (@app.QueryParam() bool updatePending,
                            @app.QueryParam() bool active,
                            @app.QueryParam() bool public) async
    {
        //Evitar buscar los objeto privados
        if (public != null)
            public = true;
        
        return Find (updatePending, userId, active, public);
    }
    
    @app.Route ('/deleteAll', methods: const [app.GET])
    @Private(ADMIN)
    @Encode()
    Future<List<ObjetoUnity>> DeleteAll (@app.QueryParam() bool updatePending,
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
        return Find(updatePending, userId, null, null);
    }
 
    Future<FileDb> ActualizarModelo (FileDb modelo, 
                                    String system,
                                    app.HttpBodyFileUpload fileUpload,
                                    String ownerId) async
    {
        //Definir nuevo form
          Map newForm = {system : fileUpload};
          
          //Resultado
          FileDb file;
          
          //Si ios ya existe
          if (modelo != null && modelo.id != null)
          {
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
                ..system = system;
              
              file = await new FileServices().NewOrUpdate
              (
                  new QueryMap (newForm),
                  metadata,
                  ownerId: ownerId
              );
          }
          
          
          return file;
    }
}