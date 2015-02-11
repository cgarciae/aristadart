part of arista;

class LocalImageTarget
{
    
    
    @Field () String path;
    @Field() String get url => path != null && path != '' ? localHost + path : '';
    
}

class LocalImageTargetSend extends LocalImageTarget
{
    @NotEmpty()
    @ReferenceId() String owner;
    
    @NotEmpty()
    @ReferenceId() String imageId;
    
    @NotEmpty()
    @Field() bool updatePending;
    
    @Range(min: 0)
    @Field () int version = 0;
    
    @ReferenceId() String datId;
    @Field() bool get activeDat => notNullOrEmpty(datId);
    @Field() bool updatedDat = false;
    
    @ReferenceId() String XmlId;
    @Field() bool get activeXml => notNullOrEmpty(XmlId);
    @Field() bool updatedXml = false;
}