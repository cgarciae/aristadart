part of aristaweb;

@Kind()
class ViewDB extends SuperModel
{
    
    @Field() int id;
    
    
    @Field() @StringProperty() String type__;

    //icon
    @Field() TextureGUI icon;
    
    //icon db
    @StringProperty() String icon__urlTextura;
    @StringProperty() String icon__texto;

    //modelo
    @Field() ObjetoUnity modelo;
        
    //modelo db
    @StringProperty() String construccionRA__modelo__url_objeto;
    @IntProperty() int construccionRA__modelo__version;

    //target
    @Field() AristaImageTarget target;
    
    //target db
    @StringProperty() String construccionRA__target__url;
    @IntProperty() int construccionRA__target__version;

    //muebles
    @Field() List<ElementoConstruccionDB> muebles;
    
    //muebles db
    @ListProperty(const ModelKeyProperty())
    List<Key> construccionRA__muebles;

    ViewDB ();

    //ConstruccionRAJS
    ViewDB.ConstruccionRA ({ObjetoUnity modelo, AristaImageTarget target, TextureGUIDB icon, List<ElementoConstruccionDB> muebles: const []})
    {
        type__ = "ConstruccionRAJS, Assembly-CSharp";

        this.icon = icon;

        this.modelo = modelo;
        this.target = target;
        this.muebles = muebles;

        if (modelo != null)
        {
            construccionRA__modelo__url_objeto = modelo.url_objeto;
            construccionRA__modelo__version = modelo.version;
        }

        if (target != null)
        {
            construccionRA__target__url = target.url;
            construccionRA__target__version = target.version;
        }

        Set (icon: icon);

    }


    Set ({TextureGUIDB icon: null})
    {
        this.icon = icon;
    }
    
    Future<ViewDB> Put ([_])
    {
        return Future.wait
        (
            muebles.map ((ElementoConstruccionDB e) => e.Put())
        )
        .then(Pack)
        .then (super.Put);
    }

    Pack ([_])
    {
        print ("View.PACK");
        
        if (icon != null)
        {
            icon__urlTextura = icon.urlTextura;
            icon__texto = icon.texto;
        }

        if (modelo != null)
        {
            construccionRA__modelo__url_objeto = modelo.url_objeto;
            construccionRA__modelo__version = modelo.version;
        }

        if (target != null)
        {
            construccionRA__target__url = target.url;
            construccionRA__target__version = target.version;
        }

        if (muebles != null)
        {
            construccionRA__muebles = muebles.map((e) => e.key).toList();
        }
    }

    Future<View> Build ()
    {
        if (icon__urlTextura != null || icon__texto != null)
        {
            icon = new TextureGUIDB.New
            (
                urlTextura: icon__urlTextura,
                texto: icon__texto 
            );
        }
        
        if (construccionRA__modelo__url_objeto != null ||
            construccionRA__modelo__version != null)
        {
            modelo = new ObjetoUnity.New
            (
                url_objeto: construccionRA__modelo__url_objeto,
                version: construccionRA__modelo__version
            );
        }
        
        if (construccionRA__target__url != null ||
            construccionRA__target__version != null)
        {
            target = new AristaImageTarget.New
            (
                url: construccionRA__target__url,
                version: construccionRA__target__version
            );
        }

        return db.lookup(construccionRA__muebles)

        .then((List<ElementoConstruccionDB> list)
        {
            muebles = list;
            return Future.wait
            (
                muebles.map((ElementoConstruccionDB e) => e.Build())
            );
        })

        .then(Return);
    }

}