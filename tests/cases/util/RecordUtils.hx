package cases.util;

import mysql.MySqlResult;

class RecordUtils {
    public static function toArray(result:MySqlResult):Array<Dynamic> {
        var rs = [];
        for (record in result)     {
            rs.push(record);
        }
        return rs;
    }
}