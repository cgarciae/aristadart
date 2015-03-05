part of aristadart.general;

class FileDb extends Ref
{
    @Field() String get href => localHost + 'file/$id';
    
    @Field() String system;
    @Field() String filename;
    @Field() String type;
    @Field() User owner;
}

class ListFileDb extends Resp
{
    @Field() List<FileDb> images;
}

abstract class FileDbType
{
    static const String imagen = "imagen";
    static const String objetoUnity = "objetoUnity";
    static const String dat = "dat";
    static const String xml = "xml";
}