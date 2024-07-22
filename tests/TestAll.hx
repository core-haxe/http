package;

import utest.ui.common.HeaderDisplayMode;
import utest.ui.Report;
import utest.Runner;
import cases.*;

class TestAll {
    public static function main() {
        var runner = new Runner();
        
        runner.addCase(new TestUrl());
        runner.addCase(new TestBasic());
        runner.addCase(new TestQueryParams());
        runner.addCase(new TestQueryParamsAlt());
        runner.addCase(new TestHeaders());
        runner.addCase(new TestQueryParamsAndHeaders());
        runner.addCase(new TestQueryParamsAltAndHeaders());
        runner.addCase(new TestRetry());
        runner.addCase(new TestPayload());
        runner.addCase(new TestErrors());
        runner.addCase(new TestRedirect());
        runner.addCase(new TestRequestTransformation());
        runner.addCase(new TestResponseTransformation());
        runner.addCase(new TestDeepCoin());
        #if nodejs // currently on server impl for nodejs
            runner.addCase(new TestHttpServer());
            runner.addCase(new TestHttpsServer());
        #end

        Report.create(runner, SuccessResultsDisplayMode.AlwaysShowSuccessResults, HeaderDisplayMode.NeverShowHeader);
        runner.run();
    }
}