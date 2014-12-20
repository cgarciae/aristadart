part of aristaclient;

class ExperienciaCL
{

    @Field() String get type__ => "ExperienciaJS, Assembly-CSharp";

    @Field() List<ViewCL> vistas = [];
    
    //CONSTRUCTORS
    ExperienciaCL ();

    ExperienciaCL.New ({List<ViewCL> vistas})
    {
        this.vistas = vistas;
    }

}