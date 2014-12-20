part of aristaweb;

@Kind()
class TextureGUIRoot extends Model {}

@Kind()
class TextureGUIDB extends SuperModel with TextureGUI
{
    @StringProperty() String urlTextura;
    
    @StringProperty() String texto;
    
    TextureGUIDB ();
    
    TextureGUIDB.New ({this.urlTextura: "", this.texto: ""});
    
}