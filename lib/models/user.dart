part of aristadart.general;

class User
{
    @Id() String id;
    @Field() String nombre;
    @Field() String apellido;
    @Field() String email;
    
    @ReferenceId() List<String> eventos = [];
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

