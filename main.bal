import ballerina/http;
import ballerina/sql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;


type User record {|
    readonly int id;
    string name;
    string city;
    string coordinates;
|};

type NewUser record {|
    string name;
    string city;
    string coordinates;
|};

configurable string host = ?;
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable int port = ?;
postgresql:Client dbClient =  check new(host, username, password,database, port);

service /api on new http:Listener(9090) {
    
    //Return all users
    resource function get allusers() returns User[]|error{
        stream<User, sql:Error?> result = dbClient -> query(`SELECT * FROM userdata`);
        return from var user in result select user; 
    }

    //Return a specific user by id
    resource function get userbyid/[int id]() returns User|error {
        User|sql:Error result = dbClient -> queryRow(`SELECT * FROM userdata WHERE id=${id}`);
        return result;
    }

    //Create new user
    resource function post newuser(NewUser data) returns http:Created|error {
       return error(""); 
    }

}
