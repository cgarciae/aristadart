part of aristadart.server;

@app.Group ('/${Col.cloudTarget}')
@Catch()
class CloudTargetServices extends AristaService<CloudTarget>
{
    EventoServices eventoServices;
    CloudTargetServices (this.eventoServices) : super (Col.cloudTarget);
    
    @app.DefaultRoute (methods: const[app.POST])
    @Private()
    @Encode()
    Future<CloudTarget> New (@app.QueryParam() String eventoId) async
    {
        var target = new CloudTarget()
            ..id = newId()
            ..evento = (new Evento()
                ..id = eventoId);
          
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
    Future<CloudTarget> NewFromImage (@app.Body(app.FORM) Map form,
                                      @app.QueryParam() String eventoId) async
    {
        if (eventoId == null)
            throw new app.ErrorResponse (400, "Query Parm eventoId requerido");
        
        //Verificar existencia: lanza error si no existe
        await eventoServices.Get(eventoId);
            
        
        CloudTarget target = await New(eventoId);
            
        if (target.failed)
            return target;
        
        //Get file
        HttpBodyFileUpload file = FormToFileUpload(form);
        
        //Subir la imagen a vuforia
        VuforiaResponse response = await VuforiaServices.newImage
        (
            file.content, //Imagen
            eventoId //El id es metadata
        );
        
        //Si el upload fracaso
        if (response.result_code != VuforiaResultCode.Success && response.result_code != VuforiaResultCode.TargetCreated)
            throw new app.ErrorResponse(400, "Fracaso subir imagen a vuforia: ${response.result_code}");
        
                
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
            throw new app.ErrorResponse(400, "Imagen no existe");
        
        if (target.target == null || target.target.id == null)
            throw new app.ErrorResponse(400, "Target no existe");
        
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
    
    @app.Route ('/:id/metadata', methods: const[app.GET])
    @Private(ADMIN)
    @Encode()
    Future<VuforiaResponse> GetMetadata (String id) async
    {
        CloudTarget target = await Get (id);
        
        VuforiaResponse resp = await new VuforiaServices().GetTarget(target.target.target_id);
        
        return resp;
    }
    
    @app.Route ('/:id/metadata', methods: const[app.PUT])
    @Private(ADMIN)
    @Encode()
    Future<CloudTarget> UpdateMetadata (String id, @app.QueryParam() String metadata) async
    {
        CloudTarget target = await Get (id);
        
        VuforiaResponse resp = await VuforiaServices.updateMetadata(target.target.target_id, metadata);
        
        return target;
    }
}

