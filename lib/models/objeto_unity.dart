part of arista;

class ObjetoUnity
{
    @Id() String id;
    @Field() String name;
}

class ObjetoUnitySend extends ObjetoUnity
{
    @ReferenceId() String owner;
    @ReferenceId() String userFileId;
    @Field() bool get active => modelId != null && modelId != '';
    @Field() int version;
    @ReferenceId() String screenshotId;
    @Field() bool updatePending;
    
    @ReferenceId() String modelId;
    @Field() String get url_objeto
    {
        if (! active)
            return "";
        
        return localHost + 'public/file/' + modelId;
    }
}