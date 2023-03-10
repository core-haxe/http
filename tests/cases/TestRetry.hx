package cases;

import http.HttpError;
import utest.Assert;
import http.HttpClient;
import utest.Async;

@:timeout(20000)
class TestRetry extends TestBase {
    private static inline var BASE_URL:String = "https://httpbin.org";

    function setupClass() {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
    }

    function teardownClass() {
        logging.LogManager.instance.clearAdaptors();
    }

    function testRetry_Default(async:Async) {
        var client = new HttpClient();
        client.retryDelayMs = 0;
        client.get('${BASE_URL}/status/500').then(result -> {
            Assert.fail("shouldnt get here");
            async.done();
        }, (error:HttpError) -> {
            Assert.equals(500, error.httpStatus);
            Assert.equals(0, error.retryCount);
            async.done();
        });
    }

    function testRetry_More(async:Async) {
        var client = new HttpClient();
        client.retryDelayMs = 0;
        client.retryCount = 5;
        client.get('${BASE_URL}/status/500').then(result -> {
            Assert.fail("shouldnt get here");
            async.done();
        }, (error:HttpError) -> {
            Assert.equals(500, error.httpStatus);
            Assert.equals(5, error.retryCount);
            async.done();
        });
    }

    function testRetry_Less(async:Async) {
        var client = new HttpClient();
        client.retryDelayMs = 0;
        client.retryCount = 1;
        client.get('${BASE_URL}/status/500').then(result -> {
            Assert.fail("shouldnt get here");
            async.done();
        }, (error:HttpError) -> {
            Assert.equals(500, error.httpStatus);
            Assert.equals(1, error.retryCount);
            async.done();
        });
    }

    function testRetry_Zero(async:Async) {
        var client = new HttpClient();
        client.retryCount = 0;
        client.retryDelayMs = 0;
        client.get('${BASE_URL}/status/500').then(result -> {
            Assert.fail("shouldnt get here");
            async.done();
        }, (error:HttpError) -> {
            Assert.equals(500, error.httpStatus);
            Assert.equals(0, error.retryCount);
            async.done();
        });
    }

    function testRetry_Null(async:Async) {
        var client = new HttpClient();
        client.retryCount = null;
        client.retryDelayMs = 0;
        client.get('${BASE_URL}/status/500').then(result -> {
            Assert.fail("shouldnt get here");
            async.done();
        }, (error:HttpError) -> {
            Assert.equals(500, error.httpStatus);
            Assert.equals(0, error.retryCount);
            async.done();
        });
    }
}