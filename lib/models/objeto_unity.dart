part of arista;

class ObjetoUnity
{
    @Id() String id;
    @ReferenceId() String userFile;
    @Field() String name;
}

class ObjetoUnitySend extends ObjetoUnity
{
    @Field() bool active;
    @Field() int version;
    @ReferenceId() String screenshotId;
}

class ObjetoUnityAdmin extends ObjetoUnitySend
{
    @Field () String path;
    @Field() String get url_objeto
    {
        if (path == null || path == '' || ! active)
            return "";
        
        return localHost + path;
    }
}