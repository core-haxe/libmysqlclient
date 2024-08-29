package cases.util;

import mysql.MySqlClient;
import mysql.MySqlClientConnection;
import promises.Promise;

class DBCreator {
    public static var connection:MySqlClientConnection;

    public static function createConnection(db:String = null):MySqlClientConnection {
        var host = Sys.getEnv("MYSQL_HOST");
        var user = Sys.getEnv("MYSQL_USER");
        var pass = Sys.getEnv("MYSQL_PASS");
        var port = 3306;

        return MySqlClient.open(host, user, pass, db, port);
    }

    public static function create(createDummyData:Bool = true):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            try {
                connection = createConnection();
                
                connection.query("CREATE DATABASE IF NOT EXISTS persons;");

                connection.query("USE persons");

                connection.query("CREATE TABLE IF NOT EXISTS Person (
                    personId int AUTO_INCREMENT,
                    lastName varchar(50),
                    firstName varchar(50),
                    iconId int,
                    contractDocument blob,
                    PRIMARY KEY (personId)
                );");
    
                connection.query("CREATE TABLE IF NOT EXISTS Icon (
                    iconId int,
                    path varchar(50)
                );");
    
                connection.query("CREATE TABLE IF NOT EXISTS Organization (
                    organizationId int,
                    name varchar(50),
                    iconId int
                );");
    
                connection.query("CREATE TABLE IF NOT EXISTS Person_Organization (
                    Person_personId int,
                    Organization_organizationId int
                );");
    
                connection.query("TRUNCATE TABLE Person;");
                connection.query("TRUNCATE TABLE Icon;");
                connection.query("TRUNCATE TABLE Organization;");
                connection.query("TRUNCATE TABLE Person_Organization;");

                addDummyData().then(_ -> {
                    resolve(true);
                }, error -> {
                    reject(error);
                });
            } catch (e:Dynamic) {
                trace("error", e);
                throw e;
            }
        });
    }

    public static function addDummyData():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            connection.query("INSERT INTO Icon (iconId, path) VALUES (1, '/somepath/icon1.png');");
            connection.query("INSERT INTO Icon (iconId, path) VALUES (2, '/somepath/icon2.png');");
            connection.query("INSERT INTO Icon (iconId, path) VALUES (3, '/somepath/icon3.png');");

            connection.query("INSERT INTO Person (personId, firstName, lastName, iconId, contractDocument) VALUES (1, 'Ian', 'Harrigan', 1, X'746869732069732069616e7320636f6e747261637420646f63756d656e74');");
            connection.query("INSERT INTO Person (personId, firstName, lastName, iconId) VALUES (2, 'Bob', 'Barker', 3);");
            connection.query("INSERT INTO Person (personId, firstName, lastName, iconId) VALUES (3, 'Tim', 'Mallot', 2);");
            connection.query("INSERT INTO Person (personId, firstName, lastName, iconId) VALUES (4, 'Jim', 'Parker', 1);");

            connection.query("INSERT INTO Organization (organizationId, name, iconId) VALUES (1, 'ACME Inc', 2);");
            connection.query("INSERT INTO Organization (organizationId, name, iconId) VALUES (2, 'Haxe LLC', 1);");
            connection.query("INSERT INTO Organization (organizationId, name, iconId) VALUES (3, 'PASX Ltd', 3);");

            connection.query("INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (1, 1);");
            connection.query("INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (2, 1);");
            connection.query("INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (3, 1);");
            connection.query("INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (2, 2);");
            connection.query("INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (4, 2);");
            connection.query("INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (1, 3);");
            connection.query("INSERT INTO Person_Organization (Person_personId, Organization_organizationId) VALUES (4, 3);");

            resolve(true);
        });
    }

    public static function delete():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            try {
                connection.query("DROP DATABASE IF EXISTS persons;");
                resolve(true);
            } catch (e:Dynamic) {
                trace("error", e);
                throw e;
            }
        });
    }
}