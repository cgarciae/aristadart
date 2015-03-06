part of aristadart.general;

class TextureGUI
{
    @Field() String path;
    @Field() bool web = true;    
    @Field() FileDb file;
    @Field() String get urlTextura
    {
        if (web)
            return file != null ? file.href : missingImage;
        else
            return path != null ? path : missingImage;
    }

    @Field() String texto = '';

    @Field() String get type__ => "TextureGUIJS, Assembly-CSharp";

    @Id() String id;
}