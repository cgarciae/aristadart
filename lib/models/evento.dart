part of arista;

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
}
