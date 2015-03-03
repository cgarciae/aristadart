part of aristadart.general;

class LocalImageTarget extends Ref
{
    @Field() String name;

    @NotEmpty()
    @Field() User owner;
    
    @NotEmpty()
    @Field() FileDb imageId;
    
    @NotEmpty()
    @Field() bool updatePending;
    
    @Range(min: 0)
    @Field () int version = 0;
    
    @Field () bool get active => activeDat && activeXml;
    @Field() bool get updated => updatedDat && updatedXml;
    
    @Field() FileDb datFile;
    @Field() bool get activeDat => datFile != null && notNullOrEmpty(datFile.id);
    @Field() bool updatedDat = false;
    
    @Field() FileDb xmlFile;
    @Field() bool get activeXml => xmlFile != null && notNullOrEmpty(xmlFile.id);
    @Field() bool updatedXml = false;
}