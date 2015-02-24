part of arista;

class ObjetoUnity
{
    @Id() String id;
    @Field() String name;
}

class ObjetoUnitySend extends ObjetoUnity
{
    @Field() String nameGameObject;
    @ReferenceId() String owner;
    @ReferenceId() String userFileId;
    
    @Field() bool get active => activeAndroid && activeIOS;
    @Field() bool get activeAll => activeAndroid && activeIOS && activeMAC && activeWindows;
    @Field() bool get updated => updatedAndroid && updatedIOS;
    @Field() bool get updatedAll => updatedAndroid && updatedIOS && updatedMAC && updatedWindows;
    @Field() int version;
    @ReferenceId() String screenshotId;
    @Field() bool updatePending;
    
    @ReferenceId() String modelIdAndroid;
    @Field() bool get activeAndroid => notNullOrEmpty(modelIdAndroid);
    @Field() bool updatedAndroid;
    
    @ReferenceId() String modelIdIOS;
    @Field() bool get activeIOS => notNullOrEmpty(modelIdIOS);
    @Field() bool updatedIOS;
    
    @ReferenceId() String modelIdWindows;
    @Field() bool get activeWindows => notNullOrEmpty(modelIdWindows);
    @Field() bool updatedWindows;
    
    @ReferenceId() String modelIdMAC;
    @Field() bool get activeMAC => notNullOrEmpty(modelIdMAC);
    @Field() bool updatedMAC = false;
    
    init(){
      this.name = 'Nuevo Modelo';
      this.version = 0;
      this.updatePending = false;
      this.updatedAndroid = false;
      this.updatedIOS = false;
      this.updatedWindows = false;
      this.updatedMAC= false;
    }
}