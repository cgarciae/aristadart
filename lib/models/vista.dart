part of aristadart.general;

class VistaTotal
{
    //Info general
    @Field() User owner;
    @Id() String id;
    @Field() String type__;
    @Field() String nombre;

    //ConstruccionRA
    @Field() ObjetoUnity objetoUnity;
    @Field() LocalImageTarget localTarget;
    @Field() List<ElementoInteractivo> cuartos;
    @Field() List<ElementoInteractivo> muebles;
    
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
                v = Cast(ConstruccionRA, this);
                break;
            default:
                v = Cast(Vista, this);
                break;
                
        }
        
        return v;
    }
}

class Vista extends Ref
{
    
    String get type__ => null;
    int get typeNum => -1;
    User owner;
    String nombre;
    String descripcion;
    String get icon => null;
    String get href => null;
    bool get valid => false;
    

    static Vista Factory ([String type__])
    {
        if (type__ == VistaType.construccionRA)
            return new ConstruccionRA()
                ..elementosInteractivos = [];
        
        return new EmptyVista();
    }
    
    
    static const Map<int,String> IndexToType = const
    {
        1 : VistaType.construccionRA
    };
    
    static Vista MapToVista (decoder, Map map)
    {
        
        var type = map['type__'];
        
        if (type == VistaType.construccionRA)
            return decoder(map, ConstruccionRA);
        
        return decoder(map, EmptyVista);
    }    
}

class EmptyVista extends Vista
{
    @Field() User owner;
    @Field() String nombre;
    @Field() String descripcion;
        
    @Field() String get type__ => null;
    @Field() int get typeNum => 0;
    @Field() String get href => localHost + 'vista/$id';
    @Field() String get icon => IconDir.missingImage;
    
    bool get valid => false;
}

class ConstruccionRA extends Vista
{
    @Field() String get type__ => VistaType.construccionRA;
    @Field() int get typeNum => 1;
    @Field() User owner;
    @Field() String nombre;
    @Field() String descripcion;
    @Field() String get icon => IconDir.icon3D;
    @Field() String get href => localHost + 'vista/$id';
    
    
    @Field() ObjetoUnity objetoUnity;
    @Field() LocalImageTarget localTarget;
    @Field() List<ElementoInteractivo> elementosInteractivos;
    
    
    @Field() bool get valid
    {
        if (objetoUnity == null || ! objetoUnity.active)
            return false;
        
        if (localTarget == null || ! localTarget.active)
            return false;
        
        return true;
    } 

}

abstract class VistaType
{
    static const String construccionRA = "ConstruccionRAJS, Assembly-CSharp";
}