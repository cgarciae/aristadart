part of aristadart.general;

class UserDb extends Ref
{
    @Field() String get href => id != null ? localHost + 'user/$id' : null;
    
    @Field() String nombre;
    @Field() String apellido;
    @Field() String email;
    
    //TODO: buscar eventos por medio de eventos.owner
    //@Field() List<Ref> eventos;
}

class User extends UserDb
{
    
}

class UserAdmin extends User
{
    @Field() bool admin;
}

class UserSecure extends User
{
    @Field() String password;
}

class UserMoney extends User
{
    @Field() num money = 0;
}

class UserComplete extends User
{
    @Field() num money = 0;
    @Field() String password;
    @Field() bool admin;
}

