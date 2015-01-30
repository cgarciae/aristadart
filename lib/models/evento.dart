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

class Active extends Object
{
    @Field() bool active;
}

class Exportable extends Object
{
    @Field() List<VistaExportable> vistas;
}

class EventoCompleto extends Evento with Active
{
    
}

class EventoActive extends Evento with Active
{
    
}

class EventoExportable extends Evento with Exportable
{
    
}
