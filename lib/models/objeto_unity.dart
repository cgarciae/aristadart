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
    @Field() bool get activeAndroid => notNullOrEmpty(modelIdAndroid);
    
    @ReferenceId() String modelIdIOS;
    @Field() bool get activeIOS => notNullOrEmpty(modelIdIOS);
    
    @ReferenceId() String modelIdWindows;
    @Field() bool get activeWindows => notNullOrEmpty(modelIdWindows);
    
    @ReferenceId() String modelIdMAC;
    @Field() bool get activeMAC => notNullOrEmpty(modelIdMAC);
}