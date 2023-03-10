package cases;

import http.HttpError;
import utest.Assert;
import http.HttpClient;
import utest.Async;

@:timeout(20000)
class TestErrors extends TestBase {
    private static var BASE_URL:String = "https://httpbin.org";

    function setupClass() {
        BASE_URL = host();
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
    }

    function teardownClass() {
        logging.LogManager.instance.clearAdaptors();
    }

    function testGet_500(async:Async) {
        var client = new HttpClient();
        client.retryDelayMs = 0;
        client.retryCount = 0;
        client.get('${BASE_URL}/status/500').then(result -> {
            Assert.fail("shouldnt get here");
            async.done();
        }, (error:HttpError) -> {
            Assert.equals("", error.bodyAsString);
            Assert.equals(500, error.httpStatus);
            async.done();
        });
    }

    function testGet_404(async:Async) {
        var client = new HttpClient();
        client.retryDelayMs = 0;
        client.retryCount = 0;
        client.get('${BASE_URL}/status/404').then(result -> {
            Assert.fail("shouldnt get here");
            async.done();
        }, (error:HttpError) -> {
            Assert.equals("", error.bodyAsString);
            Assert.equals(404, error.httpStatus);
            async.done();
        });
    }
}