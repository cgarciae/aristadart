part of arista;

class TextureGUI
{
    @Field() String path = '';
    
    @Field() String get urlTextura => localHost + path;

    @Field() String texto = '';

    @Field() String get type__ => "TextureGUIJS, Assembly-CSharp";

    @Id() String id;
}