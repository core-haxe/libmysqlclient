package cases;

import cases.util.RecordUtils;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.Test;

class TestInnerJoin extends Test {
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

    function testBasicInnerJoin(async:Async) {
        var connection = DBCreator.createConnection("persons");
        var rs = RecordUtils.toArray(connection.query("SELECT * FROM Person
            INNER JOIN Icon ON Person.iconId = Icon.iconId
        "));

        Assert.equals(4, rs.length);

        /* cant guarantee order - need to just make sure the right things exist
        Assert.equals(rs[0].personId, 1);
        Assert.equals(rs[0].firstName, "Ian");
        Assert.equals(rs[0].lastName, "Harrigan");
        Assert.equals(rs[0].iconId, 1);
        Assert.equals(rs[0].path, "/somepath/icon1.png");

        Assert.equals(rs[2].personId, 3);
        Assert.equals(rs[2].firstName, "Tim");
        Assert.equals(rs[2].lastName, "Mallot");
        Assert.equals(rs[2].iconId, 2);
        Assert.equals(rs[2].path, "/somepath/icon2.png");
        */

        connection.close();
        async.done();
    }

    function testBasicInnerJoinWhere(async:Async) {
        var connection = DBCreator.createConnection("persons");
        var rs = RecordUtils.toArray(connection.query("SELECT * FROM Person
            INNER JOIN Icon ON Person.iconId = Icon.iconId
        WHERE personId = 1"));

        Assert.equals(1, rs.length);

        Assert.equals(rs[0].personId, 1);
        Assert.equals(rs[0].firstName, "Ian");
        Assert.equals(rs[0].lastName, "Harrigan");
        Assert.equals(rs[0].iconId, 1);
        Assert.equals(rs[0].path, "/somepath/icon1.png");

        connection.close();
        async.done();
    }

    function testBasicInnerJoinWhereOr(async:Async) {
        var connection = DBCreator.createConnection("persons");
        var rs = RecordUtils.toArray(connection.query("SELECT * FROM Person
            INNER JOIN Icon ON Person.iconId = Icon.iconId
        WHERE personId = 1 OR personId = 4"));

        Assert.equals(2, rs.length);

        /* cant guarantee order - need to just make sure the right things exist
        Assert.equals(rs[0].personId, 4);
        Assert.equals(rs[0].firstName, "Jim");
        Assert.equals(rs[0].lastName, "Parker");
        Assert.equals(rs[0].iconId, 1);
        Assert.equals(rs[0].path, "/somepath/icon1.png");

        Assert.equals(rs[1].personId, 1);
        Assert.equals(rs[1].firstName, "Ian");
        Assert.equals(rs[1].lastName, "Harrigan");
        Assert.equals(rs[1].iconId, 1);
        Assert.equals(rs[1].path, "/somepath/icon1.png");
        */

        connection.close();
        async.done();
    }

    function testBasicInnerJoinWhereAnd(async:Async) {
        var connection = DBCreator.createConnection("persons");
        var rs = RecordUtils.toArray(connection.query("SELECT * FROM Person
            INNER JOIN Icon ON Person.iconId = Icon.iconId
        WHERE personId = 1 AND firstName = 'Ian'"));

        Assert.equals(1, rs.length);

        Assert.equals(rs[0].personId, 1);
        Assert.equals(rs[0].firstName, "Ian");
        Assert.equals(rs[0].lastName, "Harrigan");
        Assert.equals(rs[0].iconId, 1);
        Assert.equals(rs[0].path, "/somepath/icon1.png");

        connection.close();
        async.done();
    }
    
}