part of arista;

class Evento
{
    @Field() TextureGUI imagenPreview = new TextureGUI();

    @Id () String id;
    
    @Field () String nombre = '';
    @Field () String descripcion = '';
    
    @ReferenceId() List<String> viewIds = [];

    @Field () String get type__ => "EventoJS, Assembly-CSharp";

    @Field() String get url => localHost + "/id/$id";

}

class EventoExportable extends Evento
{
    @Field() List<VistaExportable> vistas;
}
