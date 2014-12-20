part of aristaweb;

@Kind()
class EventoDB extends SuperModel with Evento
{
    //FIELDS
    @StringProperty() String imagenPreview__urlTextura;

    @StringProperty() String nombre;
    @StringProperty() String descripcion;
    
    @IntProperty() int id;

    @ListProperty(const ModelKeyProperty())
    List<Key> viewKeys = [];

    //override
    @Field () ExperienciaDB experiencia;
    
    //CONSTRUCTORS    
    EventoDB ()
    {
        experiencia = new ExperienciaDB();
    }

    EventoDB.New ({this.nombre, this.descripcion, int id, ExperienciaDB experiencia, TextureGUIDB imagenPreview})
    {
        this.id = id;
        this.imagenPreview = imagenPreview;
        this.experiencia = experiencia;
    }



    //METHODS
    Future<EventoDB> Put ([_])
    {

        return
            experiencia.Put()
            .then(Pack)
            .then(super.Put);
    }

    Pack ([_])
    {
        print ("Evento.PACK");

        imagenPreview__urlTextura = imagenPreview.urlTextura;
        
        viewKeys = experiencia.vistas.map ((ViewDB v) => v.key).toList();
        
    }
    
    Future<EventoDB> Build ([_])
    {
        imagenPreview = new TextureGUIDB.New
        (
            urlTextura: imagenPreview__urlTextura
        );
        
        
        return experiencia
                .Build (viewKeys)
                .then (Return);
    }
}
   