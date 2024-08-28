package mysql;

import haxe.Exception;
import cpp.RawPointer;
import mysql.RawMySql.MySqlHandle;
import cpp.Finalizable;

@:unreflective
class MySqlConnection extends Finalizable {
    private var _refs:Int = 0;
    private var _handle:RawPointer<MySqlHandle> = null;

    public function new() {
        super();
        if (_handle == null) {
            _handle = RawMySql.init(null);
        }
        _refs++;
    }

    public override function finalize() {
        close();
        _refs--;
        if (_refs == 0) {
            RawMySql.close(_handle);
            RawMySql.library_end();
            _handle = null;
        }
        super.finalize();
    }

    public function lastInsertRowId():Int {
        return RawMySql.insert_id(_handle);
    }

    public function open(host:String, user:String, pass:String, db:String = null, port:Int = 0) {
        var clientFlags = 0;
        _handle = RawMySql.real_connect(_handle, host, user, pass, db, port, null, clientFlags);
        if (_handle == null) {
            throw new Exception(error());
        }
    }

    public function close() {
        if (_handle != null) {
            RawMySql.close(_handle);
            _handle = null;
        }
    }

    public function query(sql:String):MySqlResult {
        if (_handle == null) {
            throw new Exception("internal handle is null");
        }
        var n = RawMySql.query(_handle, sql);
        if (n != 0) {
            throw new MySqlError(error(), errorno());
        }
        var nativeResult = RawMySql.store_result(_handle);
        var result = new MySqlResult();
        @:privateAccess result.nativeResult = nativeResult;
        return result;
    }

    public function error():String {
        if (_handle != null) {
            return RawMySql.error(_handle);
        }
        return null;
    }

    public function errorno():Int {
        if (_handle != null) {
            return RawMySql.errno(_handle);
        }
        return 0;
    }
}