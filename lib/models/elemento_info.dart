part of aristadart.general;

class ElementoInfo
{
    @Field() String type__;
    
    //TituloInfoJS
    @Field() String titulo;
    
    //ImagenInfoJS
    @ReferenceId() String imageId;
    @Field() String get  url =>  imageId != null && imageId != '' ? localHost + imageId : '';
    
    
    //InfoTextoJS
    //titulo
    @Field() String descripcion;
}