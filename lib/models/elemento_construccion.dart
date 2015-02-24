part of aristadart.general;


class ElementoConstruccion
{
    @Field() String get type__ => "ElementoConstruccionJS, Assembly-CSharp";
    @Field() String nombre = "";
    @Field() String titulo = "";
    @ReferenceId() String imageId;
    @Field() String texto = "";

    @Field() String get urlImagen =>  notNullOrEmpty(imageId) ? localHost + 'public/file/$imageId' : '';
}
