part of arista;

class AristaImageTarget
{
    @Field () String url;
    @Field () int version;
    
    AristaImageTarget ();
    
    AristaImageTarget.New ({this.url, this.version});
}