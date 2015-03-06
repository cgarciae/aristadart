part of aristadart.general;

class TextureGUI
{
    @Field() String path;
    @Field() bool web = true;    
    @Field() FileDb file;
    @Field() String get urlTextura
    {
        if (web)
            return file != null ? file.href : IconDir.missingImage;
        else
            return path != null ? path : IconDir.missingImage;
    }

    @Field() String texto = '';

    @Field() String get type__ => "TextureGUIJS, Assembly-CSharp";

    @Id() String id;
}