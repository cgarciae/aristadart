part of aristadart.general;

class ElementoInfo
{
    @Field() String type__;
    
    //TituloInfoJS
    @Field() String titulo;
    
    //TODO: Cambiar "@Field() String path" por "@ReferenceId() String imageId", que debe ser un ObjectId de Mongo
    //Debido a esto, hay que cambiar en Angular como se muestran las imagenes de ElementoInfo en la vista InfoContacto
    
    //ImagenInfoJS
    @ReferenceId() String imageId;
    @Field() String get  url =>  imageId != null && imageId != '' ? localHost + imageId : '';
    
    
    //InfoTextoJS
    //titulo
    @Field() String descripcion;
}