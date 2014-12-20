part of aristaweb;

@Kind()
class ElementoConstruccionDB extends SuperModel
{
    @Field() String get type__ => "ElementoConstruccionJS, Assembly-CSharp";
        
    @Field() @StringProperty() String nombre = "";
    @Field() @StringProperty() String titulo = "";
    @Field() @StringProperty() String urlImagen = "";
    @Field() @StringProperty() String texto = "";
    @Field() int id;

    ElementoConstruccionDB ();

    ElementoConstruccionDB.New ({this.nombre, this.titulo, this.urlImagen, this.texto});

    Future<ElementoConstruccionDB> Build ([_])
    {
        return Return();
    }
}
