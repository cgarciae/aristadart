part of aristadart.server;

@app.Group ('/${Col.cloudTarget}')
@Catch()
class CloudTargetServices extends AristaService<CloudTarget>
{
    CloudTargetServices () : super (Col.cloudTarget);
    
    @app.DefaultRoute (methods: const[app.POST])
    @Private()
    @Encode()
    Future<CloudTarget> New () async
    {
        var target = new CloudTarget()
            ..id = newId();
          
        return NewGeneric(target);

    }
    
    @app.Route ('/:id', methods: const[app.GET])
    @Encode()
    Future<CloudTarget> Get (String id) async
    {
        return GetGeneric(id);
    }
    
    @app.Route ('/:id', methods: const[app.PUT])
    @Private()
    @Encode()
    Future<CloudTarget> Update (String id, @Decode() CloudTarget delta) async
    {
        await UpdateGeneric(id, delta);
        return Get (id);
    }
    
    @app.Route ('/:id', methods: const[app.PUT])
    @Private()
    @Encode()
    Future<CloudTarget> Delete (String id) async
    {
        return DeleteGeneric(id);
    }
    
    @app.Route ('/newFromImage', methods: const[app.POST], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<CloudTarget> NewFromImage (@app.Body(app.FORM) Map form) async
    {
        CloudTarget target = await New();
            
        if (target.failed)
            return target;
        
        //Get file
        HttpBodyFileUpload file = FormToFileUpload(form);
        
        //Subir la imagen a vuforia
        VuforiaResponse response = await VuforiaServices.newImage
        (
            file.content, //Imagen
            target.id //El id es metadata
        );
        
        //Si el upload fracaso
        if (response.result_code != VuforiaResultCode.Success && response.result_code != VuforiaResultCode.TargetCreated)
            throw new Exception("Fracaso subir imagen a vuforia: ${response.result_code}");
        
                
        //Subir la imagen a Mongo
        FileDb image = await new FileServices().NewOrUpdate (form, new FileDb());
         
        //Crear cambios
        var delta = new CloudTarget()
            ..image = image
            ..target = (new VuforiaTargetRecord()
                ..target_id = response.target_id);
        
        return Update(target.id, delta);
    }
    
    
    @app.Route ('/:id/updateFromImage', methods: const[app.PUT], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<CloudTarget> UpdateFromImage (String id, @app.Body(app.FORM) Map form) async
    {
        CloudTarget target = await Get(id);
        
        if (target.image == null || target.image.id == null)
            throw new Exception("Imagen no existe");
        
        if (target.target == null || target.target.id == null)
            throw new Exception("Target no existe");
        
        HttpBodyFileUpload file = FormToFileUpload(form);
        
        FileDb image = await new FileServices ().Update(target.image.id, form);
        VuforiaResponse response = await VuforiaServices.updateImage
        (
            target.target.id,
            file.content //Imagen
        );
        
        //Crear cambios
        var delta = new CloudTarget()
            ..image = (new FileDb()
                ..id = image.id)
            ..target = response.target_record;
        
        return Update (id, delta);
    }
}

