part of aristadart.general;

class User extends Ref
{
    @Field() String get href => id != null ? localHost + 'user/$id' : null;
    
    @Field() String nombre;
    @Field() String apellido;
    @Field() String email;
    
}
class ProtectedUser extends User
{   
    @Field() num money = 0;
    @Field() bool admin;
}

