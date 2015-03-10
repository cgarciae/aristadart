part of aristadart.general;

class ObjetoUnity extends Ref
{
    @Field() String get nombre => name;
    set nombre (String value) => name = value;
    
    @Field() String name;
    @Field() String descripcion;
    @Field() bool public;
    
    @Field() String get nameGameObject => "aristaGameObject";
    
    @Field() String get href => id != null ? localHost + Col.objetoUnity + '/$id' : null;
    
    @Field() User owner;
    @Field() FileDb userFile;
    
    bool get active => activeAndroid && activeIOS;
    bool get activeAll => activeAndroid && activeIOS && activeMAC && activeWindows;
    bool get updated => androidUpdated && iosUpdated;
    bool get updatedAll => androidUpdated && iosUpdated && osxUpdated && windowsUpdated;
    
    @Field() int version;
    @Field() FileDb screenshot;
    @Field() bool updatePending;
    
    @Field() FileDb android;
    bool get activeAndroid => android != null && notNullOrEmpty (android.id);
    @Field() bool androidUpdated;
    
    @Field() FileDb ios;
    bool get activeIOS => ios != null && notNullOrEmpty (ios.id);
    @Field() bool iosUpdated;
    
    @Field() FileDb windows;
    bool get activeWindows => windows != null && notNullOrEmpty (windows.id);
    @Field() bool windowsUpdated;
    
    @Field() FileDb osx;
    @Field() bool get activeMAC => osx != null && notNullOrEmpty (osx.id);
    @Field() bool osxUpdated;
    
}

class ListObjetoUnityResp extends Resp
{
    @Field() List<ObjetoUnity> list;
}