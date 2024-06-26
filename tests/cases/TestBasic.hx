package cases;

import http.HttpError;
import utest.Assert;
import http.HttpClient;
import utest.Async;

@:timeout(20000)
class TestBasic extends TestBase {
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

    function testGet(async:Async) {
        var client = new HttpClient();
        client.get('${BASE_URL}/get').then(response -> {
            Assert.notNull(response.body);
            var json = response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals(host() + "/get", json.url);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }

    function testPost(async:Async) {
        var client = new HttpClient();
        client.post('${BASE_URL}/post').then(response -> {
            Assert.notNull(response.body);
            var json = response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals(host() + "/post", json.url);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }

    function testPut(async:Async) {
        var client = new HttpClient();
        client.put('${BASE_URL}/put').then(response -> {
            Assert.notNull(response.body);
            var json = response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals(host() + "/put", json.url);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }

    function testDelete(async:Async) {
        var client = new HttpClient();
        client.delete('${BASE_URL}/delete').then(response -> {
            Assert.notNull(response.body);
            var json = response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals(host() + "/delete", json.url);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }
}