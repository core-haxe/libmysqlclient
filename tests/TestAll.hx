package;

import utest.ui.common.HeaderDisplayMode;
import utest.ui.Report;
import utest.Runner;
import cases.*;

class TestAll {
    public static function main() {
        var runner = new Runner();
        
        trace("MYSQL_HOST: " + Sys.getEnv("MYSQL_HOST"));
        trace("MYSQL_USER: " + Sys.getEnv("MYSQL_USER"));
        trace("MYSQL_PASS: " + Sys.getEnv("MYSQL_PASS"));

        runner.addCase(new TestQuery());
        runner.addCase(new TestInsert());
        runner.addCase(new TestInnerJoin());
        runner.addCase(new TestBlob());

        Report.create(runner, SuccessResultsDisplayMode.AlwaysShowSuccessResults, HeaderDisplayMode.NeverShowHeader);
        runner.run();
    }
}