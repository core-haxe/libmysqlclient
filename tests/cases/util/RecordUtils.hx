package cases.util;

import mysql.MySqlClientResult;

class RecordUtils {
    public static function toArray(result:MySqlClientResult):Array<Dynamic> {
        var rs = [];
        for (record in result)     {
            rs.push(record);
        }
        return rs;
    }
}