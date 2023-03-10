package cases;

import http.HttpError;
import utest.Assert;
import http.HttpClient;
import utest.Async;

@:timeout(20000)
class TestBasic extends TestBase {
    private static inline var BASE_URL:String = "https://httpbin.org";

    function setupClass() {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
    }

    function teardownClass() {
        logging.LogManager.instance.clearAdaptors();
    }

    function testGet(async:Async) {
        var client = new HttpClient();
        client.get('${BASE_URL}/get').then(result -> {
            Assert.notNull(result.response.body);
            var json = result.response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals("https://httpbin.org/get", json.url);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }

    function testPost(async:Async) {
        var client = new HttpClient();
        client.post('${BASE_URL}/post').then(result -> {
            Assert.notNull(result.response.body);
            var json = result.response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals("https://httpbin.org/post", json.url);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }

    function testPut(async:Async) {
        var client = new HttpClient();
        client.put('${BASE_URL}/put').then(result -> {
            Assert.notNull(result.response.body);
            var json = result.response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals("https://httpbin.org/put", json.url);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }

    function testDelete(async:Async) {
        var client = new HttpClient();
        client.delete('${BASE_URL}/delete').then(result -> {
            Assert.notNull(result.response.body);
            var json = result.response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals("https://httpbin.org/delete", json.url);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }
}