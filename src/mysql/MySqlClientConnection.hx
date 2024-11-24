package mysql;

import haxe.Exception;
import cpp.Finalizable;
import cpp.NativeArray;
import cpp.NativeString;
import cpp.Pointer;
import cpp.RawPointer;
import mysql.RawMySqlClient.MySqlHandle;

@:unreflective
class MySqlClientConnection extends Finalizable {
    private static var _refs:Int = 0;
    private var _handle:RawPointer<MySqlHandle> = null;

    public function new() {
        super();
        if (_handle == null) {
            _handle = RawMySqlClient.init(null);
        }
        _refs++;
    }

    public override function finalize() {
        close();
        _refs--;
        RawMySqlClient.close(_handle);
        _handle = null;
        if (_refs == 0) {
            RawMySqlClient.library_end();
        }
        super.finalize();
    }

    public function lastInsertRowId():Int {
        return RawMySqlClient.insert_id(_handle);
    }

    public function affectedRows():Int {
        return RawMySqlClient.affected_rows(_handle);
    }

    public function open(host:String, user:String, pass:String, db:String = null, port:Int = 0) {
        var clientFlags = 0;
        _handle = RawMySqlClient.real_connect(_handle, host, user, pass, db, port, null, clientFlags);
        if (_handle == null) {
            throw new Exception(error());
        }
    }

    public function close() {
        if (_handle != null) {
            RawMySqlClient.close(_handle);
            _handle = null;
        }
    }

    public function query(sql:String):MySqlClientResult {
        if (_handle == null) {
            throw new Exception("internal handle is null");
        }
        var n = RawMySqlClient.query(_handle, sql);
        if (n != 0) {
            throw new MySqlClientError(error(), errorno());
        }
        var nativeResult = RawMySqlClient.store_result(_handle);
        var result = new MySqlClientResult();
        @:privateAccess result.nativeResult = nativeResult;
        return result;
    }

    public function error():String {
        if (_handle != null) {
            return RawMySqlClient.error(_handle);
        }
        return null;
    }

    public function errorno():Int {
        if (_handle != null) {
            return RawMySqlClient.errno(_handle);
        }
        return 0;
    }

    public function escapeString(value:String):String {
        // throw exception when handle is null
        if (_handle == null) {
            throw new Exception("internal handle is null");
        }
        // get utf8 lenght and multiply it by 2 to have enough space
        var len = NativeString.utf8Length(value) * 2 + 1;
        // generate native array with length elements
        var na = NativeArray.create(len);
        // create pointer to native array
        var p = Pointer.arrayElem(na, 0);
        // call real escape string
        var result = RawMySqlClient.real_escape_string(_handle, p.raw, value, value.length);
        // get untyped error return variable
        untyped __cpp__("unsigned long errorReturn = (unsigned long)-1");
        // handle error
        if (untyped __cpp__("{0} == {1}", result, errorReturn)) {
            throw new Exception("mysql_real_escape_string failed!");
        }
        // return escaped string
        return new String(untyped __cpp__("{0}", p.constRaw));
    }
}