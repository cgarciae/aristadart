part of arista;

class User
{
    @Id() String id;
    @Field() String username;
    @Field() bool admin;
    
    @ReferenceId() List<String> eventos = [];
}

class UserSecure extends User
{
    @Field() String password;
}
