part of aristadart.general;

class VistaTotal
{
    //Info general
    @Id() String id;
    @Field() List<Evento> eventos;
    @Field() String type__;
    @Field() TextureGUI icon;

    //ConstruccionRA
    @Field() ObjetoUnity objetoUnity;
    @Field() LocalImageTarget localTarget;
    @Field() List<ElementoConstruccion> cuartos;
    @Field() List<ElementoConstruccion> muebles;
    
    //InfoContacto
    @Field() List<ElementoContacto> elementosContacto;
    @Field() List<ElementoInfo> elementosInfo;
    
    //Multimedia
    @Field() List<TextureGUI> textures;
    
    //MapaConstruccion
    @Field() String center;
    @Field() int zoom;
    @Field() String texto;
    
    Vista get vista
    {
        Vista v;
        
        switch (type__)
        {
            case "ConstruccionRAJS, Assembly-CSharp":
                v = new ConstruccionRA()
                    ..id = id
                    ..icon = icon
                    ..eventos = eventos
                    
                    ..objetoUnity = objetoUnity
                    ..localTarget = localTarget
                    ..cuartos = cuartos
                    ..muebles = muebles;
                break;
            default:
                v = new EmptyVista();
                break;
                
        }
        
        return v;
    }
}

class Vista extends Ref
{
    @Field() List<Evento> eventos;
    @Field() String get type__ => null;
    @Field() String get href => localHost + 'vista/$id';
    @Field() TextureGUI icon;
    
    static Vista Factory ([String type__])
    {
        Vista v;
        switch (type__)
        {
            case VistaType.construccionRA:
                v = new ConstruccionRA();
                break;
            default:
                v = new Vista();
                break;
        }
        
        return v;
    }
    
    
    Resp valid () => new Resp()..error = "Vista sin type__";
}

class ConstruccionRA extends Vista
{
    @Field() String get href => localHost + 'vista/$id';
    @Field() String get type__ => VistaType.construccionRA;
    
    @Field() ObjetoUnity objetoUnity;
    @Field() LocalImageTarget localTarget;
    @Field() List<ElementoConstruccion> cuartos;
    @Field() List<ElementoConstruccion> muebles;
    
    Resp valid ()
    {
        Resp resp = super.valid();
        
        if (resp.failed)
            return resp;
        
        if (objetoUnity == null)
            return new Resp()
                ..error = "modeloId undefined.";
        
        if (objetoUnity.active == null || objetoUnity.active == false)
            return new Resp()
                ..error = "El objetoUnity no esta activo.";
        
        if (localTarget == null)
            return new Resp()
                ..error = "localTarget undefined.";   
        
        if (localTarget.active == null || localTarget.active == false)
             return new Resp()
                ..error = "El localTarget no esta activo.";
        
        return new Resp();
    }
}

abstract class VistaType
{
    static const String construccionRA = "ConstruccionRAJS, Assembly-CSharp";
}

class TA
{
    @Id() String id;
    @Field () String nombre;
    @Field () TA ref;
    
    TA()
    {
        nombre = "!";
    }
}

class TB extends TA
{
    
}