part of aristadart.general;


class ElementoInteractivo
{
    //tag busca el objecto en la escena
    @Field() String tag;
    
    @Field() String get type__ => "ElementoConstruccionJS, Assembly-CSharp";
    @Field() String titulo = "";
    @Field() FileDb image;
    @Field() String texto = "";
}
