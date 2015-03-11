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

abstract class Vista extends Ref
{
    String get type__;
    int get typeNum;
    User owner;
    String nombre;
    String descripcion;
    String get icon;
    
    static Vista Factory ([String type__])
    {
        Vista v;
        switch (type__)
        {
            case VistaType.construccionRA:
                v = new ConstruccionRA()
                    ..elementosInteractivos = [];
                break;
            default:
                v = new EmptyVista();
                break;
        }
        
        return v;
    }
    
    
    static const Map<int,String> IndexToType = const
    {
        1 : VistaType.construccionRA
    };
    
    static Vista MapToVista (decoder, Map map)
    {
        var type = map['type__'];

        switch (type)
        {
            case VistaType.construccionRA:
                ConstruccionRA vista = decoder(map, ConstruccionRA);
                return vista;
            default:
                return decoder(map, EmptyVista);
        }
        
    }
    
}

class EmptyVista extends Ref implements Vista
{
    @Field() User owner;
    @Field() String nombre;
    @Field() String descripcion;
        
    @Field() String get type__ => null;
    @Field() int get typeNum => 0;
    @Field() String get href => localHost + 'vista/$id';
    @Field() String get icon => IconDir.missingImage;
}

class ConstruccionRA extends Ref implements Vista
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

}

abstract class VistaType
{
    static const String construccionRA = "ConstruccionRAJS, Assembly-CSharp";
}