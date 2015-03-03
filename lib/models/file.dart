part of aristadart.general;

class FileDb extends Ref
{
    @Field() String get href => localHost + 'file/$id';
    
    @Field() String nombre;
}