package cases;

import haxe.Timer;
import utest.Async;
import utest.ITest;

@:timeout(20000)
class TestBase implements ITest {
    public function new() {
    }

    function setup(async:Async) {
        Timer.delay(function() {
            async.done();
        }, 1000);
    }
}