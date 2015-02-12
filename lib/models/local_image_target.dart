part of arista;

class LocalImageTarget
{
    @Id () String id;
    @Field() String name;
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
    
    @Field() bool get updatedAll => updatedDat && updatedXml;
    
    @ReferenceId() String datId;
    @Field() bool get activeDat => notNullOrEmpty(datId);
    @Field() bool updatedDat = false;
    
    @ReferenceId() String xmlId;
    @Field() bool get activeXml => notNullOrEmpty(xmlId);
    @Field() bool updatedXml = false;
}