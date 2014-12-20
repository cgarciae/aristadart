part of aristageneral;

class Evento
{
    @Field() TextureGUI imagenPreview;

    @Field () int id;
    @Field () String nombre;
    @Field () String descripcion;

    @Field () String get type__ => "EventoJS, Assembly-CSharp";

    @Field() String get url => localHost + "/id/$id";

}