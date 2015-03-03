part of aristadart.general;

class ObjetoUnity extends Ref
{
    @Field() String name;
    @Field() String nameGameObject;
    
    @Field() String get href => id != null ? "${localHost}public/objetounity/${id}" : null;
    
    @Field() User owner;
    @Field() Ref userFileId;
    
    bool get active => activeAndroid && activeIOS;
    bool get activeAll => activeAndroid && activeIOS && activeMAC && activeWindows;
    bool get updated => updatedAndroid && updatedIOS;
    bool get updatedAll => updatedAndroid && updatedIOS && updatedMAC && updatedWindows;
    
    @Field() int version;
    @Field() FileDb screenshotId;
    @Field() bool updatePending;
    
    @Field() FileDb modelIdAndroid;
    bool get activeAndroid => modelIdAndroid != null && notNullOrEmpty (modelIdAndroid.id);
    @Field() bool updatedAndroid;
    
    @Field() FileDb modelIdIOS;
    bool get activeIOS => modelIdIOS != null && notNullOrEmpty (modelIdIOS.id);
    @Field() bool updatedIOS;
    
    @Field() FileDb modelIdWindows;
    bool get activeWindows => modelIdWindows != null && notNullOrEmpty (modelIdWindows.id);
    @Field() bool updatedWindows;
    
    @Field() FileDb modelIdMAC;
    @Field() bool get activeMAC => modelIdMAC != null && notNullOrEmpty (modelIdMAC.id);
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