package mysql;

import cpp.RawPointer;

@:unreflective
class MySqlClient {
    public static function open(host:String, user:String, pass:String, db:String = null, port:Int = 0):MySqlClientConnection {
        var connection = new MySqlClientConnection();
        connection.open(host, user, pass, db, port);
        return connection;
    }
}