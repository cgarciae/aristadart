part of aristadart.general;

class LocalImageTarget extends Ref
{
    @Field() String get nombre => name;
    set nombre (String value) => name = value;
    
    @Field() String get href => localHost + Col.localTarget + '/$id';
    
    @Field() String name;
    @Field() bool public;

    @Field() User owner;
    
    @Field() FileDb image;

    @Field() bool updatePending;

    @Field () int version = 0;
    
    @Field () bool get active => activeDat && activeXml;
    @Field() bool get updated => datUpdated && xmlUpdated;
    
    @Field() FileDb dat;
    @Field() bool get activeDat => dat != null && notNullOrEmpty(dat.id);
    @Field() bool datUpdated = false;
    
    @Field() FileDb xml;
    @Field() bool get activeXml => xml != null && notNullOrEmpty(xml.id);
    @Field() bool xmlUpdated = false;
}

class ListLocalImageTargetResp extends Resp
{
    @Field() List<LocalImageTarget> list;
}