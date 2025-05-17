package cases;

import cases.util.RecordUtils;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.Test;

class TestQuery extends Test {
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
    
    function testBasicSelect(async:Async) {
        var connection = DBCreator.createConnection("persons");
        var rs = RecordUtils.toArray(connection.query("SELECT * FROM Person"));

        Assert.equals(4, rs.length);

        Assert.equals(rs[0].personId, 1);
        Assert.equals(rs[0].firstName, "Ian");
        Assert.equals(rs[0].lastName, "Harrigan");
        Assert.equals(rs[0].iconId, 1);
        Assert.equals(rs[0].amount, 123.456);

        Assert.equals(rs[2].personId, 3);
        Assert.equals(rs[2].firstName, "Tim");
        Assert.equals(rs[2].lastName, "Mallot");
        Assert.equals(rs[2].iconId, 2);
        Assert.equals(rs[2].amount, 222.333);

        connection.close();
        async.done();
    }

    function testBasicSelectWhere(async:Async) {
        var connection = DBCreator.createConnection("persons");
        var rs = RecordUtils.toArray(connection.query("SELECT * FROM Person WHERE personId = 1"));

        Assert.equals(1, rs.length);

        Assert.equals(rs[0].personId, 1);
        Assert.equals(rs[0].firstName, "Ian");
        Assert.equals(rs[0].lastName, "Harrigan");
        Assert.equals(rs[0].iconId, 1);
        Assert.equals(rs[0].amount, 123.456);
        
        connection.close();
        async.done();
    }

    function testBasicSelectWhereOr(async:Async) {
        var connection = DBCreator.createConnection("persons");
        var rs = RecordUtils.toArray(connection.query("SELECT * FROM Person WHERE personId = 1 OR personId = 4"));

        Assert.equals(2, rs.length);

        Assert.equals(rs[0].personId, 1);
        Assert.equals(rs[0].firstName, "Ian");
        Assert.equals(rs[0].lastName, "Harrigan");
        Assert.equals(rs[0].iconId, 1);
        Assert.equals(rs[0].amount, 123.456);

        Assert.equals(rs[1].personId, 4);
        Assert.equals(rs[1].firstName, "Jim");
        Assert.equals(rs[1].lastName, "Parker");
        Assert.equals(rs[1].iconId, 1);
        Assert.equals(rs[1].amount, 333.444);
        
        connection.close();
        async.done();
    }

    function testBasicSelectWhereAnd(async:Async) {
        var connection = DBCreator.createConnection("persons");
        var rs = RecordUtils.toArray(connection.query("SELECT * FROM Person WHERE personId = 1 AND firstName = 'Ian'"));

        Assert.equals(1, rs.length);

        Assert.equals(rs[0].personId, 1);
        Assert.equals(rs[0].firstName, "Ian");
        Assert.equals(rs[0].lastName, "Harrigan");
        Assert.equals(rs[0].iconId, 1);
        Assert.equals(rs[0].amount, 123.456);
        
        connection.close();
        async.done();
    }
}