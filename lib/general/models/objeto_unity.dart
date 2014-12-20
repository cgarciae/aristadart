part of aristageneral;

class ObjetoUnity
{
    @Field () String url_objeto;
    @Field () int version;
    
    ObjetoUnity ();
    
    ObjetoUnity.New ({this.url_objeto, this.version});
}