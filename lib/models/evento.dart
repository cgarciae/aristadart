part of arista;

class Evento
{
    @Field() TextureGUI imagenPreview = new TextureGUI();
    @Id () String id;
    @Field () String nombre = '';
    @Field () String descripcion = '';
    
    @Field() String get url => localHost + "/export/evento/$id";
    
    @ReferenceId() List<String> viewIds = [];
}

class EventoExportable extends Evento
{
    @Field() List<VistaExportable> vistas;
}
