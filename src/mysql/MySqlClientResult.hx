package mysql;

import cpp.RawPointer;
import cpp.ConstCharStar;
import mysql.RawMySqlClient.MySqlRes;
import mysql.RawMySqlClient.MySqlField;
import mysql.RawMySqlClient.MySqlFieldType;
import cpp.Finalizable;
import cpp.Pointer;
import haxe.io.BytesData;
import haxe.io.Bytes;
import cpp.NativeArray;

@:unreflective
class MySqlClientResult extends Finalizable {
    public var fieldNames:Array<String> = [];
    public var fieldTypes:Array<Int> = [];

    private var _rowCount:Int = 0;

    public function new() {
        super();
    }

    public override function finalize() {
        free();
        super.finalize();
    }

    private var _nativeResult:RawPointer<MySqlRes> = null;
    private var nativeResult(get, set):RawPointer<MySqlRes>;
    private function get_nativeResult():RawPointer<MySqlRes> {
        return _nativeResult;
    }
    private function set_nativeResult(value:RawPointer<MySqlRes>):RawPointer<MySqlRes> {
        _nativeResult = value;
        populateCache();
        return value;
    }

    private function populateCache() {
        _rowCount = 0;
        fieldNames = [];
        fieldTypes = [];

        if (_nativeResult == null) {
            return;
        }

        _rowCount = RawMySqlClient.num_rows(_nativeResult);

        var fieldCount = RawMySqlClient.num_fields(_nativeResult);
        for (i in 0...fieldCount) {
            var field = RawMySqlClient.fetch_field_direct(_nativeResult, i);
            var fieldPointer:Pointer<MySqlField> = Pointer.fromRaw(field);

            fieldNames.push(fieldPointer.ptr.name);
            fieldTypes.push(fieldPointer.ptr.type);
        }
    }

    public var length(get, null):Int;
    private function get_length():Int {
        return _rowCount;
    }

    @:noCompletion
    public function iterator():MySqlResultDataIterator {
        var it = new MySqlResultDataIterator();
        @:privateAccess it._nativeResult = _nativeResult;
        @:privateAccess it._fieldTypes = fieldTypes;
        @:privateAccess it._fieldCount = fieldTypes.length;
        return it;
    }

    public function free() {
        if (_nativeResult != null) {
            RawMySqlClient.free_result(_nativeResult);
            _nativeResult = null;
        }
    }
}

@:unreflective
private class MySqlResultDataIterator {
    private var _nativeResult:RawPointer<MySqlRes> = null;
    private var _fieldTypes:Array<Int> = [];
    private var _fieldCount:Int;

    private var _current:Int = -1;
    private var _rowCount:Int = -1;

    public function new() {
    }

    private var _prepared:Bool = false;
    public function prepare() {
        if (_prepared) {
            return;
        }
        _prepared = true;
        _current = 0;
        if (_nativeResult == null) {
            return;
        }
        _rowCount = RawMySqlClient.num_rows(_nativeResult);
    }

    public function hasNext():Bool {
        prepare();
        return _current <= (_rowCount - 1);
    }

    #if mysql_results_as_rows

    public function next():Array<Any> {
        prepare();
        RawMySqlClient.data_seek(_nativeResult, _current);
        var row = RawMySqlClient.fetch_row(_nativeResult);
        var lens = RawMySqlClient.fetch_lengths(_nativeResult);
        
        var dataArray:Array<Any> = [];
        for (i in 0..._fieldCount) {
            var len = untyped __cpp__("{0}[{1}]", lens, i);
            var type = _fieldTypes[i];
            var rawData:ConstCharStar = untyped __cpp__("{0}[{1}]", row, i);

            var value:Any = null;
            if (type == MySqlFieldType.VAR_STRING) {
                value = new String(rawData);
            } else if (type == MySqlFieldType.STRING) {
                value = new String(rawData);
            } else if (type == MySqlFieldType.JSON) {
                value = haxe.Json.parse(new String(rawData));
            } else if (type == MySqlFieldType.LONG) {
                value = Std.parseInt(rawData);
            } else if (type == MySqlFieldType.LONGLONG) {
                value = Std.parseInt(rawData);
            } else if (type == MySqlFieldType.DATETIME) {
                value = new String(rawData); // TODO: proper date time
            } else if (type == MySqlFieldType.TIMESTAMP) {
                value = new String(rawData); // TODO: proper date time
            } else if (type == MySqlFieldType.DOUBLE) {
                value = Std.parseFloat(rawData);
            } else if (type == MySqlFieldType.NEWDECIMAL) {
                value = Std.parseFloat(rawData);
            } else if (type == MySqlFieldType.BLOB) {
                if (len > 0) {
                    var bytesData:BytesData = NativeArray.create(len);
                    NativeArray.zero(bytesData);
                    untyped __cpp__("memcpy({0}, {1}, {2})", NativeArray.address(bytesData, 0), rawData, len);
                    value = Bytes.ofData(bytesData);
                } else {
                    value = null;
                }
            } else {
                trace("unknown mysql field type (" + name + ":" + type + ") [" + rawData + "]");
            }

            dataArray.push(value);
        }

        _current++;
        return dataArray;
    }

    #else

    public function next():Dynamic {
        prepare();
        RawMySqlClient.data_seek(_nativeResult, _current);
        var row = RawMySqlClient.fetch_row(_nativeResult);
        var lens = RawMySqlClient.fetch_lengths(_nativeResult);
        
        var dataObject:Dynamic = {};
        for (i in 0..._fieldCount) {
            var len = untyped __cpp__("{0}[{1}]", lens, i);
            var type = _fieldTypes[i];
            var field:RawPointer<MySqlField> = RawMySqlClient.fetch_field_direct(_nativeResult, i);
            // no idea why i had to use untyped here
            var name:String = untyped __cpp__("{0}->name", field);
            var rawData:ConstCharStar = untyped __cpp__("{0}[{1}]", row, i);

            var value:Any = null;
            if (type == MySqlFieldType.VAR_STRING) {
                value = new String(rawData);
            } else if (type == MySqlFieldType.STRING) {
                value = new String(rawData);
            } else if (type == MySqlFieldType.JSON) {
                value = haxe.Json.parse(new String(rawData));
            } else if (type == MySqlFieldType.LONG) {
                value = Std.parseInt(rawData);
            } else if (type == MySqlFieldType.LONGLONG) {
                value = Std.parseInt(rawData);
            } else if (type == MySqlFieldType.DATETIME) {
                value = new String(rawData); // TODO: proper date time
            } else if (type == MySqlFieldType.TIMESTAMP) {
                value = new String(rawData); // TODO: proper date time
            } else if (type == MySqlFieldType.DOUBLE) {
                value = Std.parseFloat(rawData);
            } else if (type == MySqlFieldType.NEWDECIMAL) {
                value = Std.parseFloat(rawData);
            } else if (type == MySqlFieldType.BLOB) {
                if (len > 0) {
                    var bytesData:BytesData = NativeArray.create(len);
                    NativeArray.zero(bytesData);
                    untyped __cpp__("memcpy({0}, {1}, {2})", NativeArray.address(bytesData, 0), rawData, len);
                    value = Bytes.ofData(bytesData);
                } else {
                    value = null;
                }
            } else {
                trace("unknown mysql field type (" + name + ":" + type + ") [" + rawData + "]");
            }

            Reflect.setField(dataObject, name, value);
        }

        _current++;
        return dataObject;
    }

    #end
}