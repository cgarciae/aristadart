part of aristadart.general;

class Evento extends Ref
{
    @Field() String get href => localHost + "evento/$id";
    
    @Field() User owner;
    
    @Field() FileDb imagenPreview;
    @Field () String nombre;
    @Field () String descripcion;
    @Field() bool active;
    @Field() bool demo;
    
    @Field() List<Vista> vistas;
    @Field() CloudTarget cloudTarget;
    
    bool get valid
    {
        if (id == null || id == "")
            return false;
        
        if (active == null || ! active)
            return false;
        
        if (cloudTarget == null || cloudTarget.id == null)
            return false;
        
        if (vistas.length == 0)
            return false;
        
        return true;
    }
}
