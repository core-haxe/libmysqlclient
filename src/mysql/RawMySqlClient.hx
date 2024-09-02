package mysql;

import cpp.ConstCharStar;
import cpp.RawPointer;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@:buildXml('
    <set name="lib_folder" value="${haxelib:libmysqlclient}/lib" />
    <set name="include_folder" value="${haxelib:libmysqlclient}/lib" />
    <echo value="Using libmysqlclient from: ${lib_folder}" />
    <section if="windows">
        <files id="haxe">
            <compilerflag value="-I${include_folder}" />
            <compilerflag value="-I${include_folder}/include" />
        </files>

        <target id="haxe" tool="linker" toolid="exe">
            <lib name="${lib_folder}/mysqlclient.lib"/>
            <lib name="advapi32.lib" />
        </target>
    </section>
')
@:include("mysql.h")
@:unreflective
extern class RawMySqlClient {
    @:native("::mysql_init")                        public static function init(mysql:RawPointer<MySqlHandle>):RawPointer<MySqlHandle>;
    @:native("::mysql_library_end")                 public static function library_end():Void;

    @:native("::mysql_error")                       public static function error(mysql:RawPointer<MySqlHandle>):ConstCharStar;
    @:native("::mysql_errno")                       public static function errno(mysql:RawPointer<MySqlHandle>):Int;
    @:native("::mysql_real_connect")                public static function real_connect(mysql:RawPointer<MySqlHandle>, host:ConstCharStar, user:ConstCharStar, passwd:ConstCharStar, db:ConstCharStar, port:Int, unix_socket:ConstCharStar, clientflag:Int):RawPointer<MySqlHandle>;
    @:native("::mysql_close")                       public static function close(mysql:RawPointer<MySqlHandle>):Void;
    @:native("::mysql_affected_rows")               public static function affected_rows(mysql:RawPointer<MySqlHandle>):Int;
    @:native("::mysql_insert_id")                   public static function insert_id(mysql:RawPointer<MySqlHandle>):Int;

    @:native("::mysql_real_escape_string")          public static function real_escape_string(mysql:RawPointer<MySqlHandle>, to:RawPointer<cpp.Char>, from:ConstCharStar, length:Int):Int;
    @:native("::mysql_real_escape_string_quote")    public static function real_escape_string_quote(mysql:RawPointer<MySqlHandle>, to:RawPointer<cpp.Char>, from:ConstCharStar, length:Int, quote:cpp.Char):Int;

    @:native("::mysql_query")                       public static function query(mysql:RawPointer<MySqlHandle>, q:ConstCharStar):Int;
    @:native("::mysql_store_result")                public static function store_result(mysql:RawPointer<MySqlHandle>):RawPointer<MySqlRes>;
    @:native("::mysql_free_result")                 public static function free_result(result:RawPointer<MySqlRes>):Void;

    @:native("::mysql_fetch_row")                   public static function fetch_row(result:RawPointer<MySqlRes>):MySqlRow;
    @:native("::mysql_num_rows")                    public static function num_rows(result:RawPointer<MySqlRes>):Int;
    @:native("::mysql_num_fields")                  public static function num_fields(result:RawPointer<MySqlRes>):Int;
    @:native("::mysql_eof")                         public static function eof(result:RawPointer<MySqlRes>):Bool;
    @:native("::mysql_data_seek")                   public static function data_seek(result:RawPointer<MySqlRes>, offset:Int):Void;

    @:native("::mysql_fetch_lengths")               public static function fetch_lengths(result:RawPointer<MySqlRes>):RawPointer<UnsignedLong>;
    @:native("::mysql_fetch_field")                 public static function fetch_field(result:RawPointer<MySqlRes>):RawPointer<MySqlField>;
    @:native("::mysql_fetch_fields")                public static function fetch_fields(result:RawPointer<MySqlRes>):RawPointer<MySqlField>;
    @:native("::mysql_fetch_field_direct")          public static function fetch_field_direct(result:RawPointer<MySqlRes>, fieldnr:Int):RawPointer<MySqlField>;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@:include("mysql.h")
@:native("MYSQL")
@:unreflective
extern class MySqlHandle {
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@:include("mysql.h")
@:native("MYSQL_RES")
@:unreflective
extern class MySqlRes {
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@:include("mysql.h")
@:native("char**")
@:unreflective
extern class MySqlRow {
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@:include("mysql.h")
@:native("MYSQL_FIELD")
@:unreflective
extern class MySqlField {
    public var name:ConstCharStar;
    public var org_name:ConstCharStar;
    public var table:ConstCharStar;
    public var org_table:ConstCharStar;
    public var db:ConstCharStar;
    public var catalog:ConstCharStar;
    public var def:ConstCharStar;
    public var length:Int;
    public var max_length:Int;
    public var name_length:Int;
    public var org_name_length:Int;
    public var table_length:Int;
    public var org_table_length:Int;
    public var db_length:Int;
    public var catalog_length:Int;
    public var def_length:Int;
    public var flags:Int;
    public var decimals:Int;
    public var charsetnr:Int;
    public var type:Int;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@:headerCode('
#include "mysql.h"
#include "mysql_com.h"
')
class MySqlFieldType {
    public static var DECIMAL:Int = untyped __cpp__("FIELD_TYPE_DECIMAL");    
    public static var NEWDECIMAL:Int = untyped __cpp__("FIELD_TYPE_NEWDECIMAL");    
    public static var TINY:Int = untyped __cpp__("FIELD_TYPE_TINY");    
    public static var SHORT:Int = untyped __cpp__("FIELD_TYPE_SHORT");    
    public static var LONG:Int = untyped __cpp__("FIELD_TYPE_LONG");    
    public static var FLOAT:Int = untyped __cpp__("FIELD_TYPE_FLOAT");    
    public static var DOUBLE:Int = untyped __cpp__("FIELD_TYPE_DOUBLE");    
    public static var NULL:Int = untyped __cpp__("FIELD_TYPE_NULL");    
    public static var TIMESTAMP:Int = untyped __cpp__("FIELD_TYPE_TIMESTAMP");    
    public static var LONGLONG:Int = untyped __cpp__("FIELD_TYPE_LONGLONG");    
    public static var INT24:Int = untyped __cpp__("FIELD_TYPE_INT24");    
    public static var DATE:Int = untyped __cpp__("FIELD_TYPE_DATE");    
    public static var TIME:Int = untyped __cpp__("FIELD_TYPE_TIME");    
    public static var DATETIME:Int = untyped __cpp__("FIELD_TYPE_DATETIME");    
    public static var YEAR:Int = untyped __cpp__("FIELD_TYPE_YEAR");    
    public static var NEWDATE:Int = untyped __cpp__("FIELD_TYPE_NEWDATE");    
    public static var ENUM:Int = untyped __cpp__("FIELD_TYPE_ENUM");    
    public static var SET:Int = untyped __cpp__("FIELD_TYPE_SET");    
    public static var TINY_BLOB:Int = untyped __cpp__("FIELD_TYPE_TINY_BLOB");    
    public static var MEDIUM_BLOB:Int = untyped __cpp__("FIELD_TYPE_MEDIUM_BLOB");    
    public static var LONG_BLOB:Int = untyped __cpp__("FIELD_TYPE_LONG_BLOB");    
    public static var BLOB:Int = untyped __cpp__("FIELD_TYPE_BLOB");    
    public static var VAR_STRING:Int = untyped __cpp__("FIELD_TYPE_VAR_STRING");    
    public static var STRING:Int = untyped __cpp__("FIELD_TYPE_STRING");    
    public static var CHAR:Int = untyped __cpp__("FIELD_TYPE_CHAR");    
    public static var INTERVAL:Int = untyped __cpp__("FIELD_TYPE_INTERVAL");    
    public static var GEOMETRY:Int = untyped __cpp__("FIELD_TYPE_GEOMETRY");    
    public static var BIT:Int = untyped __cpp__("FIELD_TYPE_BIT");    
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@:native("unsigned long")
extern class UnsignedLong {

}