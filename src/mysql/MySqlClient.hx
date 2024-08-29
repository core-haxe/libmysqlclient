package mysql;

import cpp.RawPointer;

@:buildXml('
    <set name="lib_folder" value="${haxelib:libmysqlclient}/lib" />
    <set name="include_folder" value="${haxelib:libmysqlclient}/lib" />
    <echo value="Using libmysqlclient from: ${lib_folder}" />
    <section if="windows">
        <files id="haxe">
            <!--
            <compilerflag value="-Dmy_socket_defined" />
            -->    
            <compilerflag value="-I${include_folder}" />
        </files>

        <target id="haxe" tool="linker" toolid="exe">
            <lib name="${lib_folder}/mysqlclient.lib"/>
            <lib name="advapi32.lib" />
        </target>
    </section>
')
@:unreflective
class MySqlClient {
    public static function open(host:String, user:String, pass:String, db:String = null, port:Int = 0):MySqlClientConnection {
        var connection = new MySqlClientConnection();
        connection.open(host, user, pass, db, port);
        return connection;
    }
}