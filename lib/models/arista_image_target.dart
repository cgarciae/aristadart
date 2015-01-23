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
}

class AristaCloudRecoTargetComplete extends AristaCloudRecoTarget
{
    @ReferenceId() String imageId;
    @Field() String targetId;
}