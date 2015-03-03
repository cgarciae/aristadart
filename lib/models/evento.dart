part of aristadart.general;

class Evento extends Ref
{
    @Field() String get href => localHost + "evento/$id";
    
    @Field() User owner;
    
    @Field() TextureGUI imagenPreview;
    @Field () String nombre;
    @Field () String descripcion;
    @Field() bool active;
    
    @Field() String get url => localHost + "export/evento/$id";
    
    @Field() List<Vista2> vistas;
    @Field() CloudTarget2 cloudRecoTargetId;
    
    Resp valid ()
    {
        if (id == null || id == "")
            return new Resp()
                ..error = "Id de Evento Invalida";
        
        if (active == null || ! active)
            return new Resp()
                ..error = "Evento inactivo";
        
        if (cloudRecoTargetId == null || cloudRecoTargetId.id == null)
            return new Resp()
                ..error = "Target ID Invalida";
        
        
        vistas = vistas.where((Vista2 vista){
            
            Resp resp = vista.valid();
            
            return resp.success;
            
        }).toList();
        
        if (vistas.length == 0)
            return new Resp()
                ..error = "Ninguna vista valida disponible";
        
        return new Resp();
    }
}
