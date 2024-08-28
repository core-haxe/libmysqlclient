package mysql;

import cpp.RawPointer;
import cpp.ConstCharStar;
import mysql.RawMySql.MySqlRes;
import mysql.RawMySql.MySqlField;
import mysql.RawMySql.MySqlFieldType;
import cpp.Finalizable;
import cpp.Pointer;
import haxe.io.BytesData;
import haxe.io.Bytes;
import cpp.NativeArray;

@:unreflective
class MySqlResult extends Finalizable {
    public var fieldNames:Array<String> = [];
    public var fieldTypes:Array<Int> = [];

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
        if (_nativeResult == null) {
            return;
        }

        fieldNames = [];
        fieldTypes = [];

        var fieldCount = RawMySql.num_fields(_nativeResult);
        for (i in 0...fieldCount) {
            var field = RawMySql.fetch_field_direct(_nativeResult, i);
            var fieldPointer:Pointer<MySqlField> = Pointer.fromRaw(field);

            fieldNames.push(fieldPointer.ptr.name);
            fieldTypes.push(fieldPointer.ptr.type);
        }
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
            RawMySql.free_result(_nativeResult);
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
        _rowCount = RawMySql.num_rows(_nativeResult);
    }

    public function hasNext():Bool {
        prepare();
        return _current <= (_rowCount - 1);
    }

    #if mysql_results_as_rows

    public function next():Array<Any> {
        prepare();
        RawMySql.data_seek(_nativeResult, _current);
        var row = RawMySql.fetch_row(_nativeResult);
        var lens = RawMySql.fetch_lengths(_nativeResult);
        
        var dataArray:Array<Any> = [];
        for (i in 0..._fieldCount) {
            var len = untyped __cpp__("{0}[{1}]", lens, i);
            var type = _fieldTypes[i];
            var rawData:ConstCharStar = untyped __cpp__("{0}[{1}]", row, i);

            var value:Any = null;
            if (type == MySqlFieldType.VAR_STRING) {
                value = new String(rawData);
            } else if (type == MySqlFieldType.LONG) {
                value = Std.parseInt(rawData);
            } else if (type == MySqlFieldType.DOUBLE) {
                value = Std.parseFloat(rawData);
            } else if (type == MySqlFieldType.BLOB) {
                var bytesData:BytesData = NativeArray.create(len);
                NativeArray.zero(bytesData);
                untyped __cpp__("memcpy({0}, {1}, {2})", NativeArray.address(bytesData, 0), rawData, len);
                value = Bytes.ofData(bytesData);
            } else {
                var fields = Type.getClassFields(MySqlFieldType);
                var foundField = null;
                for (f in fields) { 
                    if (Reflect.field(MySqlFieldType, f) == type) {
                        foundField = f;
                        break;

                    }
                }
                trace("unknown mysql field type (" + type + "), detected as '" + foundField + "'");
            }

            dataArray.push(value);
        }

        _current++;
        return dataArray;
    }

    #else

    public function next():Dynamic {
        prepare();
        RawMySql.data_seek(_nativeResult, _current);
        var row = RawMySql.fetch_row(_nativeResult);
        var lens = RawMySql.fetch_lengths(_nativeResult);
        
        var dataObject:Dynamic = {};
        for (i in 0..._fieldCount) {
            var len = untyped __cpp__("{0}[{1}]", lens, i);
            var type = _fieldTypes[i];
            var field:RawPointer<MySqlField> = RawMySql.fetch_field_direct(_nativeResult, i);
            // no idea why i had to use untyped here
            var name:String = untyped __cpp__("{0}->name", field);
            var rawData:ConstCharStar = untyped __cpp__("{0}[{1}]", row, i);

            var value:Any = null;
            if (type == MySqlFieldType.VAR_STRING) {
                value = new String(rawData);
            } else if (type == MySqlFieldType.LONG) {
                value = Std.parseInt(rawData);
            } else if (type == MySqlFieldType.DOUBLE) {
                value = Std.parseFloat(rawData);
            } else if (type == MySqlFieldType.BLOB) {
                var bytesData:BytesData = NativeArray.create(len);
                NativeArray.zero(bytesData);
                untyped __cpp__("memcpy({0}, {1}, {2})", NativeArray.address(bytesData, 0), rawData, len);
                value = Bytes.ofData(bytesData);
            } else {
                var fields = Type.getClassFields(MySqlFieldType);
                var foundField = null;
                for (f in fields) { 
                    if (Reflect.field(MySqlFieldType, f) == type) {
                        foundField = f;
                        break;

                    }
                }
                trace("unknown mysql field type (" + type + "), detected as '" + foundField + "'");
            }

            Reflect.setField(dataObject, name, value);
        }

        _current++;
        return dataObject;
    }

    #end
}