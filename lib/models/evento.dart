part of aristadart.general;

class Evento
{
    @Field() TextureGUI imagenPreview = new TextureGUI();
    @Id () String id;
    @Field () String nombre = '';
    @Field () String descripcion = '';
    
    @Field() String get url => localHost + "export/evento/$id";
    
    @ReferenceId() List<String> viewIds = [];
    @ReferenceId() String cloudRecoTargetId;
}

class EventoCompleto extends Evento
{
    @Field() bool active = true;
}

class EventoExportable extends EventoCompleto
{
    @Field() List<VistaExportable> vistas;
    
    Resp valid ()
    {
        if (id == null || id == "")
            return new Resp()
                ..error = "Id de Evento Invalida";
        
        if (active == null || ! active)
            return new Resp()
                ..error = "Evento inactivo";
        
        if (cloudRecoTargetId == null || cloudRecoTargetId == "")
            return new Resp()
                ..error = "Target ID Invalida";
        
        
        //TODO: ya no es asyncronico, intentar limpiar con map y filter
        List<VistaExportable> list = [];
        List<Future> futureList = [];
        for (VistaExportable vista in vistas)
        {
            Resp resp = vista.valid();
            if (resp.success)
                list.add (vista);
            else
                print (resp.error);
        }
        
        vistas = list;
        
        if (vistas.length == 0)
            return new Resp()
                ..error = "Ninguna vista valida disponible";
        
        return new Resp();
    }
}
