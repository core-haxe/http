package cases;

import http.HttpError;
import utest.Assert;
import http.HttpClient;
import utest.Async;

@:timeout(20000)
class TestHeaders extends TestBase {
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
        client.get('${BASE_URL}/get', null, ["Header1" => "header value1", "Header2" => "header value2"]).then(result -> {
            Assert.notNull(result.response.body);
            var json = result.response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals("https://httpbin.org/get", json.url);
            Assert.equals("header value1", json.headers.Header1);
            Assert.equals("header value2", json.headers.Header2);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }

    function testPost(async:Async) {
        var client = new HttpClient();
        client.post('${BASE_URL}/post', null, null, ["Header1" => "header value1", "Header2" => "header value2"]).then(result -> {
            Assert.notNull(result.response.body);
            var json = result.response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals("https://httpbin.org/post", json.url);
            Assert.equals("header value1", json.headers.Header1);
            Assert.equals("header value2", json.headers.Header2);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }

    function testPut(async:Async) {
        var client = new HttpClient();
        client.put('${BASE_URL}/put', null, null, ["Header1" => "header value1", "Header2" => "header value2"]).then(result -> {
            Assert.notNull(result.response.body);
            var json = result.response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals("https://httpbin.org/put", json.url);
            Assert.equals("header value1", json.headers.Header1);
            Assert.equals("header value2", json.headers.Header2);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }

    function testDelete(async:Async) {
        var client = new HttpClient();
        client.delete('${BASE_URL}/delete', null, null, ["Header1" => "header value1", "Header2" => "header value2"]).then(result -> {
            Assert.notNull(result.response.body);
            var json = result.response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals("https://httpbin.org/delete", json.url);
            Assert.equals("header value1", json.headers.Header1);
            Assert.equals("header value2", json.headers.Header2);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }

    function testGet_DefaultHeaders(async:Async) {
        var client = new HttpClient();
        client.defaultRequestHeaders = [
            "Header1" => "default header value1",
            "Header2" => "default header value2",
            "Header3" => "default header value3"
        ];
        client.get('${BASE_URL}/get', null, ["Header1" => "header value1", "Header2" => "header value2"]).then(result -> {
            Assert.notNull(result.response.body);
            var json = result.response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals("https://httpbin.org/get", json.url);
            Assert.equals("header value1", json.headers.Header1);
            Assert.equals("header value2", json.headers.Header2);
            Assert.equals("default header value3", json.headers.Header3);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }
}
 