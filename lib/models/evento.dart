part of arista;

class Evento
{
    @Field() TextureGUI imagenPreview = new TextureGUI();
    @Id () String id;
    @Field () String nombre = '';
    @Field () String descripcion = '';
    
    @Field() String get url => localHost + "/export/evento/$id";
    
    @ReferenceId() List<String> viewIds = [];
    @ReferenceId() String cloudRecoTargetId;
}

class _Active extends Object
{
    @Field() bool active = false;
}

class _Exportable extends Object
{
    @Field() List<VistaExportable> vistas;
}

class EventoCompleto extends Evento with _Active
{
    
}

class EventoActive extends Evento with _Active
{
    
}

class EventoExportable extends Evento with _Exportable
{
    
}
