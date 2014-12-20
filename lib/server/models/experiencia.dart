part of aristaweb;

class ExperienciaDB
{
    @Field() String get type__ => "ExperienciaJS, Assembly-CSharp";
    
    //Override
    @Field() List<ViewDB> vistas = [];

    //CONSTRUCTORS
    ExperienciaDB ();

    ExperienciaDB.New ({List<ViewDB> vistas})
    {
        this.vistas = vistas;
    }
    

    //METHODS
    Future<ExperienciaDB> Return ([dynamic _]) => new Future.value(this);

    Future<ExperienciaDB> Build (List<Key> keys)
    {
        return db.lookup(keys)
                
        .then((List<ViewDB> list)
        {
            print(list);
            vistas = list;
            return Future.wait
            (
                vistas.map((ViewDB v) => v.Build())
            );
        })
        
        .then(Return);
    }
    
    Future<Experiencia> Put ([_])
    {
        print ("Experiencia.PUT");
        return Future.wait
        (
            vistas.map((ViewDB v) => v.Put())
        )
        .then (Return);
    }
}