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
    @Field() bool get active => activeAndroid && activeIOS;
    @Field() bool get activeAll => activeAndroid && activeIOS && activeMAC && activeWindows;
    @Field() int version;
    @ReferenceId() String screenshotId;
    @Field() bool updatePending;
    
    @ReferenceId() String modelIdAndroid;
    @Field() bool get activeAndroid => modelIdAndroid != null && modelIdAndroid != '';
    
    @ReferenceId() String modelIdIOS;
    @Field() bool activeIOS = false;
    
    @ReferenceId() String modelIdWindows;
    @Field() bool activeWindows = false;
    
    @ReferenceId() String modelIdMAC;
    @Field() bool activeMAC = false;
    
    @Field() String get url_objeto
    {
        if (! active)
            return "";
        
        return localHost + 'public/file/' + modelId;
    }
}