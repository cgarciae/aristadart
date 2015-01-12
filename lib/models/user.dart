part of arista;

class BasicUser
{
    @Id() String id;
    @Field() String username;
    @Field() String email;
    
    @ReferenceId() List<String> eventos = [];
}

class User extends BasicUser
{
    @Field() bool admin;
}

class UserSecure extends BasicUser
{
    @Field() String password;
}

class CompleteUser extends BasicUser
{
    @Field() bool admin;
    @Field() String password;
} 

