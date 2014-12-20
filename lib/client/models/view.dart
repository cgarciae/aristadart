part of aristaclient;

class ViewCL
{

    @Field() String type__;
    @Field() TextureGUI icon = new TextureGUI();

    @Field() ObjetoUnity modelo = new ObjetoUnity();
    @Field() AristaImageTarget target = new AristaImageTarget();
    
    @Field() int id;

    @Field() List<ElementoConstruccion> muebles = [];
}