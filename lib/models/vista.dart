part of arista;

class Vista
{
    //Info general
    @Id() String id;
    @Field() String type__;
    @Field() TextureGUI icon = new TextureGUI();

    //ConstruccionRA
    @Field() ObjetoUnity modelo;
    @Field() AristaImageTarget target;
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
    
    void NuevoElementoContacto (){
        if(elementosContacto == null)
            elementosContacto =[];
        elementosContacto.add(new ElementoContacto());
    }
    
    void NuevoElementoInfo (){
        if(elementosInfo == null)
                    elementosInfo =[];
        elementosInfo.add(new ElementoInfo());
    }
}

class VistaExportable extends Vista
{
    
}