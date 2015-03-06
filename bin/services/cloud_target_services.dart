part of aristadart.server;

@app.Group ('/${Col.cloudTarget}')
class CloudTargetServices
{
    @app.DefaultRoute (methods: const[app.POST])
    @Private()
    @Encode()
    Future<CloudTarget> New () async
    {
        try
        {
            var target = new CloudTarget()
                ..id = newId();
            
            await db.insert
            (
                Col.cloudTarget,
                target
            );
            
            return target;
        }
        catch (e, s)
        {
            return new CloudTarget()
                ..error = "$e $s";
        }
    }
    
    @app.Route ('/:id', methods: const[app.GET])
    @Encode()
    Future<CloudTarget> Get (String id) async
    {
        try
        {
            CloudTarget target = await db.findOne
            (
                Col.cloudTarget,
                CloudTarget,
                where.id(StringToId(id))
            );
            
            if (target == null)
                return new CloudTarget()
                    ..error = "Target no fue encontrado";
            
            return target;
        }
        catch (e, s)
        {
            return new CloudTarget()
                ..error = "$e $s";
        }
    }
    
    @app.Route ('/:id', methods: const[app.PUT])
    @Private()
    @Encode()
    Future<CloudTarget> Update (String id, @Decode() CloudTarget delta) async
    {
        try
        {
            print (encodeJson(delta));
            
            await db.update
            (
                Col.cloudTarget,
                where.id (StringToId (id)),
                getModifierBuilder(delta)
            );
            
            return Get (id);
        }
        catch (e, s)
        {
            return new CloudTarget()
                ..error = "$e $s";
        }
    }
    
    @app.Route ('/:id', methods: const[app.PUT])
    @Private()
    @Encode()
    Future<CloudTarget> Delete (String id) async
    {
        try
        {
            await db.remove
            (
                Col.cloudTarget,
                where.id (StringToId (id))
            );
            
            return new DbObj()
                ..id = id;
        }
        catch (e, s)
        {
            return new CloudTarget()
                ..error = "$e $s";
        }
    }
    
    @app.Route ('/newFromImage', methods: const[app.POST], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<CloudTarget> NewFromImage (@app.Body(app.FORM) Map form) async
    {
        try
        {
            CloudTarget target = await New();
            
            if (target.failed)
                return target;
            
            HttpBodyFileUpload file = FormToFileUpload(form);
            
            VuforiaResponse response = await VuforiaServices.newImage
            (
                file.content, //Imagen
                target.id //El id es metadata
            );
            
            if (response.result_code != VuforiaResultCode.Success && response.result_code != VuforiaResultCode.TargetCreated)
                return new CloudTarget()
                    ..error = "Fracaso subir imagen a vuforia: ${response.result_code}";
            
                    
            FileDb image = await new FileServices().NewOrUpdate (form, new FileDb());
             
            if (image.failed)
                return new CloudTarget()
                    ..error = "Fracaso guardar imagen en mongo: ${image.error}";
            
            return Update
            (
                target.id,
                new CloudTarget()
                    ..image = image
                    ..target = (new VuforiaTargetRecord()
                        ..target_id = response.target_id)
            
            );
        }
        catch (e, s)
        {
            return new CloudTarget()
                ..error = "$e $s";
        }
    }
    
    
    @app.Route ('/:id/updateFromImage', methods: const[app.POST], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<CloudTarget> UpdateFromImage (String id, @app.Body(app.FORM) Map form) async
    {
        try
        {
            CloudTarget target = await Get(id);
            
            if (target.failed)
                return target;
            
            if (target.image == null || target.image.id == null)
                return new CloudTarget()
                    ..error = "Imagen no existe";
            
            if (target.target == null || target.target.id == null)
                return new CloudTarget()
                    ..error = "Target no existe";
            
            
            HttpBodyFileUpload file = FormToFileUpload(form);
            
            //Crear una nueva imagen en mongo y vuforia simultaneamente
            List futures = await Future.wait
            ([
                new FileServices ().Update(target.image.id, form),
                VuforiaServices.updateImage
                (
                    target.target.id,
                    file.content //Imagen
                )
            ]);
            
            FileDb image = futures[0];
            VuforiaResponse response = futures[1];
            
            if (image.failed)
                return new CloudTarget()
                    ..error = "Fracaso guardar imagen en mongo";
            
            if (response.failed)
                return new CloudTarget()
                    ..error = "Fracaso subir imagen a vuforia";
            
            return target
                ..image = image
                ..target = response.target_record;
        }
        catch (e, s)
        {
            return new CloudTarget()
                ..error = "$e $s";
        }
    }
    
    @app.Route ('/:id/vuforiaTargetRecord', methods: const[app.GET])
    @Encode()
    Future<VuforiaResponse> testGetVuforiaImage (String id) async
    {
        return VuforiaServices.makeVuforiaRequest
        (
            Method.GET,
            '/targets/$id'
        );
    }
}

