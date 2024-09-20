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
|};

type UpdateCity record {|
    string city;
|};

type DataBaseConfig readonly & record {|
    string host;
    string username;
    string database;
    string password;
    int port;
|};

type GeoData record {
    string name;
    map<string> local_names;
    decimal lat;
    decimal lon;
    string country;
    string state?;
};


//External API connection
http:Client callClient = check new ("http://api.openweathermap.org");
configurable string apikey = ?;

//Create new db client config
configurable DataBaseConfig databaseConnection = ?;
postgresql:Client dbClient = check new(...databaseConnection);


//Function to get the coordinates based on city value
function getCoords(string city) returns string|http:ClientError {
    GeoData[] resp = check callClient -> get("/geo/1.0/direct?q=" + city + "&appid=" + apikey + "");
    string lat = (resp[0].lat).toString();
    string lon = (resp[0].lon).toString();

    string coordinates = "lat: " + lat + " / lon: " + lon;
    return coordinates;
}



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

        string coordinates = check getCoords(data.city);
        _ = check dbClient -> execute(`INSERT INTO userdata (name, city, coordinates) VALUES(${data.name}, ${data.city}, ${coordinates})`);
        return http:CREATED;
    }

    //Update city coordinates
    resource function patch updatecity/[int id](UpdateCity city) returns string|error {
        
        string coordinates = check getCoords(city.city);
        _ = check dbClient -> execute(`UPDATE userdata SET city=${city.city}, coordinates=${coordinates} WHERE id=${id};`);
        return "New coordinates : " + coordinates;
    }

    //Delete user
    resource function delete deleteuser/[int id]() returns string|error {
        _ = check dbClient -> execute(`DELETE FROM userdata WHERE id=${id};`);
        return "User successfully deleted";
    }
}