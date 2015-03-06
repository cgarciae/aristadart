part of aristadart.general;

class Evento extends Ref
{
    @Field() String get href => localHost + "evento/$id";
    
    @Field() User owner;
    
    @Field() FileDb imagenPreview;
    @Field () String nombre;
    @Field () String descripcion;
    @Field() bool active;
    
    @Field() String get url => localHost + "export/evento/$id";
    
    @Field() List<Vista> vistas;
    @Field() CloudTarget cloudTarget;
    
    Resp valid ()
    {
        if (id == null || id == "")
            return new Resp()
                ..error = "Id de Evento Invalida";
        
        if (active == null || ! active)
            return new Resp()
                ..error = "Evento inactivo";
        
        if (cloudTarget == null || cloudTarget.id == null)
            return new Resp()
                ..error = "Target ID Invalida";
        
        
        vistas = vistas.where((Vista vista){
            
            Resp resp = vista.valid();
            
            return resp.success;
            
        }).toList();
        
        if (vistas.length == 0)
            return new Resp()
                ..error = "Ninguna vista valida disponible";
        
        return new Resp();
    }
}
