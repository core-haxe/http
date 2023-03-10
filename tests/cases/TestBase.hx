package cases;

import haxe.Timer;
import utest.Async;
import utest.ITest;

@:timeout(20000)
class TestBase implements ITest {
    public function new() {
    }

    #if httpbin
    function setup(async:Async) {
        Timer.delay(function() {
            async.done();
        }, 1000);
    }
    #end

    function host() {
        if (Sys.getEnv("TEST_HOST") != null) {
            return Sys.getEnv("TEST_HOST");
        }
        #if httpbin
            return "https://httpbin.org";
        #end
        return "http://localhost";
    }
}