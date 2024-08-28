package cases;

import haxe.io.Bytes;
import cases.util.RecordUtils;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.Test;

class TestBlob extends Test {
    function setupClass(async:Async) {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
        async.done();
        DBCreator.create().then(_ -> {
            async.done();
        });
    }

    function teardownClass(async:Async) {
        logging.LogManager.instance.clearAdaptors();
        DBCreator.delete().then(_ -> {
            async.done();
        });
    }
    
    function testBasicBlob(async:Async) {
        var connection = DBCreator.createConnection("persons");
        var rs = RecordUtils.toArray(connection.query("SELECT * FROM Person WHERE personId = 1"));

        Assert.equals(1, rs.length);

        Assert.equals(rs[0].personId, 1);
        Assert.equals(rs[0].firstName, "Ian");
        Assert.equals(rs[0].lastName, "Harrigan");
        Assert.equals(rs[0].iconId, 1);
        Assert.isOfType(rs[0].contractDocument, Bytes);
        Assert.equals(Bytes.ofString("this is ians contract document").toString(), rs[0].contractDocument.toString());
        
        connection.close();
        async.done();
    }

    function testBasicBlobInsert(async:Async) {
        var connection = DBCreator.createConnection("persons");

        connection.query("INSERT INTO Person (lastName, firstName, iconId, contractDocument) VALUES ('new last name', 'new first name', 1, X'746869732069732061206e657720636f6e747261637420646f63756d656e74')");

        var lastInsertedId = connection.lastInsertRowId();
        Assert.equals(5, lastInsertedId);

        var rs = RecordUtils.toArray(connection.query("SELECT * FROM Person WHERE personId = " + lastInsertedId));

        Assert.equals(1, rs.length);

        Assert.equals(rs[0].personId, 5);
        Assert.equals(rs[0].firstName, "new first name");
        Assert.equals(rs[0].lastName, "new last name");
        Assert.equals(rs[0].iconId, 1);
        Assert.isOfType(rs[0].contractDocument, Bytes);
        Assert.equals(Bytes.ofString("this is a new contract document").toString(), rs[0].contractDocument.toString());
        
        connection.close();
        async.done();
    }
}