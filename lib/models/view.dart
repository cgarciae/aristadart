part of arista;

class Vista
{
    //Info general
    @Id() String id;
    
    @Field() String type__;
    @Field() TextureGUI icon = new TextureGUI();

    //Info expecifica
    @Field() ObjetoUnity modelo;
    @Field() AristaImageTarget target;
    
    
}

class VistaExportable extends Vista
{
    
}