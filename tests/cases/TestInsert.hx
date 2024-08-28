package cases;

import cases.util.RecordUtils;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.Test;

class TestInsert extends Test {
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

    function testBasicInsert(async:Async) {
        var connection = DBCreator.createConnection("persons");

        connection.query("INSERT INTO Person (lastName, firstName, iconId) VALUES ('new last name', 'new first name', 1)");

        var lastInsertedId = connection.lastInsertRowId();
        Assert.equals(5, lastInsertedId);

        var rs = RecordUtils.toArray(connection.query("SELECT * FROM Person WHERE personId = " + lastInsertedId));

        Assert.equals(1, rs.length);

        Assert.equals(rs[0].personId, 5);
        Assert.equals(rs[0].firstName, "new first name");
        Assert.equals(rs[0].lastName, "new last name");
        Assert.equals(rs[0].iconId, 1);
        
        connection.close();
        async.done();
    }
}