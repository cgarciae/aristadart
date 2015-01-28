part of arista;

class ObjetoUnity
{
    @Field () String path;
    @Field() String get url_objeto => path != null && path != '' ? localHost + path : '';
    @Field () int version;
    
    ObjetoUnity ();
    
}