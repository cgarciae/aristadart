part of arista;

class ElementoInfo
{
    @Field() String type__;
    
    //TituloInfoJS
    @Field() String titulo;
    
    //TODO: Cambiar "@Field() String path" por "@ReferenceId() String imageId", que debe ser un ObjectId de Mongo
    //Debido a esto, hay que cambiar en Angular como se muestran las imagenes de ElementoInfo en la vista InfoContacto
    
    //ImagenInfoJS
    @Field() String path;
    @Field() String get  url =>  path != null && path != '' ? localHost + path : '';
    
    
    //InfoTextoJS
    //titulo
    @Field() String descripcion;
}