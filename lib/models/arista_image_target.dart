part of arista;

class AristaImageTarget
{
    @Field () String url;
    @Field () int version;
    
    AristaImageTarget ();
    
    AristaImageTarget.New ({this.url, this.version});
}

class AristaCloudRecoTarget
{
    @Id() String id;
    @ReferenceId() String imageId;
    @Field() String targetId;
}