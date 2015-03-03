part of aristadart.general;

class ObjetoUnity extends Ref
{
    @Field() String name;
    @Field() String get href => id != null ? "${localHost}public/objetounity/${id}" : null;
}

class ObjetoUnitySend extends ObjetoUnity
{
    @Field() String nameGameObject;
    @ReferenceId() String owner;
    @ReferenceId() String userFileId;
    
    bool get active => activeAndroid && activeIOS;
    bool get activeAll => activeAndroid && activeIOS && activeMAC && activeWindows;
    bool get updated => updatedAndroid && updatedIOS;
    bool get updatedAll => updatedAndroid && updatedIOS && updatedMAC && updatedWindows;
    @Field() int version;
    @ReferenceId() String screenshotId;
    @Field() bool updatePending;
    
    @ReferenceId() String modelIdAndroid;
    bool get activeAndroid => notNullOrEmpty(modelIdAndroid);
    @Field() bool updatedAndroid;
    
    @ReferenceId() String modelIdIOS;
    bool get activeIOS => notNullOrEmpty(modelIdIOS);
    @Field() bool updatedIOS;
    
    @ReferenceId() String modelIdWindows;
    bool get activeWindows => notNullOrEmpty(modelIdWindows);
    @Field() bool updatedWindows;
    
    @ReferenceId() String modelIdMAC;
    @Field() bool get activeMAC => notNullOrEmpty(modelIdMAC);
    @Field() bool updatedMAC;
    
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

class ObjetoUnityRef extends Ref
{
    @Field() String get href => id != null ? "${localHost}public/objetounity/${id}" : null;
}

class UserRef extends Ref
{
    @Field() String get href => id != null ? "${localHost}public/user/${id}" : "${localHost}images/missing.png";
}

class User2
{
    String nombre;
}

class UserServer extends UserRef with User2
{   
    ObjetoUnityRef obj;
}

class UserClient extends UserServer
{
    ObjetoUnityClient obj;
}

class ObjetoUnityClient extends ObjetoUnityRef
{
    
}