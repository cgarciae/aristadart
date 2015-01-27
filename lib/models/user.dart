part of arista;

class User
{
    @Id() String id;
    @Field() String nombre;
    @Field() String apellido;
    @Field() String email;
    
    @ReferenceId() List<String> eventos = [];
}

class _Admin
{
    @Field() bool admin;
}

class _Password
{
    @Field() String password;
}

class _Money
{
    @Field() num money = 0;
}

class UserAdmin extends User with _Admin
{
    
}

class UserSecure extends User with _Password
{
    
}

class UserMoney extends User with _Money
{
    
}

class UserComplete extends User with _Admin, _Password, _Money
{
    
} 

