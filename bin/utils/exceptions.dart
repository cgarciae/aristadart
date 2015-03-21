part of aristadart.server;

class UserNotFound implements Exception
{
    String msg;
    
    UserNotFound ([this.msg]);
    
    String toString() => "USER NOT FOUND: ${msg != null ? msg : ''}";
}