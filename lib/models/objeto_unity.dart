part of aristadart.general;

class ObjetoUnity
{
    @Id() String id;
    @Field() String name;
}

class ObjetoUnitySend extends ObjetoUnity
{
    @Field() String get href => id != null ? "${localHost}public/objetounity/${id}" : null;
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
    @Field() bool updatedAndroid = false;
    
    @ReferenceId() String modelIdIOS;
    @Field() bool get activeIOS => notNullOrEmpty(modelIdIOS);
    @Field() bool updatedIOS = false;
    
    @ReferenceId() String modelIdWindows;
    @Field() bool get activeWindows => notNullOrEmpty(modelIdWindows);
    @Field() bool updatedWindows = false;
    
    @ReferenceId() String modelIdMAC;
    @Field() bool get activeMAC => notNullOrEmpty(modelIdMAC);
    @Field() bool updatedMAC = false;
    
}

abstract class Ref
{
    @Id() String id;
    @Field() String get href;
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

