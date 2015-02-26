part of aristadart.general;

class Vista
{
    //Info general
    @Id() String id;
    @Field() String type__;
    @Field() TextureGUI icon = new TextureGUI();

    //ConstruccionRA
    @ReferenceId() String objetoUnityId;
    @ReferenceId() String localTargetId;
    @Field() List<ElementoConstruccion> cuartos;
    @Field() List<ElementoConstruccion> muebles;
    
    //InfoContacto
    @Field() List<ElementoContacto> elementosContacto;
    @Field() List<ElementoInfo> elementosInfo;
    
    //Multimedia
    @Field() List<TextureGUI> textures;
    
    //MapaConstruccion
    @Field() String center;
    @Field() int zoom;
    @Field() String texto;
    
    void NuevoElementoContacto (){
        if(elementosContacto == null)
            elementosContacto =[];
        
        elementosContacto.add(new ElementoContacto());
    }
    
    void NuevoElementoInfo (){
        if(elementosInfo == null)
            elementosInfo =[];
        
        elementosInfo.add(new ElementoInfo());
    }
    
    void NuevaTextura (){
        if(textures == null)
                            textures =[];
        textures.add(new TextureGUI());
    }
}

class VistaExportable extends Vista
{
    //ConstruccionRA
    @Field() ObjetoUnitySend objetoUnity;
    @Field() LocalImageTargetSend localTarget;
    
    Resp valid ()
    {
        if (type__ == null || type__ == "")
            return new Resp()
                ..error = "type__ undefined.";
        
        switch (type__)
        {
            case 'ConstruccionRAJS, Assembly-CSharp':
                
                if (objetoUnity == null)
                    return new Resp()
                        ..error = "modeloId undefined.";
                if (objetoUnity.active == null || objetoUnity.active == false)
                    return new Resp()
                        ..error = "El objetoUnity no esta activo.";
                if (localTarget == null)
                    return new Resp()
                        ..error = "localTarget undefined.";            
                if (localTarget.active == null || localTarget.active == false)
                     return new Resp()
                        ..error = "El localTarget no esta activo.";            
                
                break;
        }
        
        return new Resp();
    }
}

class TA
{
    @Id() String id;
    @Field () String nombre;
    @Field () TA ref;
}