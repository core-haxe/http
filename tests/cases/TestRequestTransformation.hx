package cases;

import http.HttpRequest;
import http.IHttpRequestTransformer;
import http.HttpError;
import utest.Assert;
import http.HttpClient;
import utest.Async;

@:timeout(20000)
class TestRequestTransformation extends TestBase {
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

    function testBasic(async:Async) {
        var client = new HttpClient();
        client.requestTransformers = [new AddHeaders()];
        client.get('${BASE_URL}/get').then(response -> {
            Assert.notNull(response.body);
            var json = response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals(host() + "/get", json.url);
            Assert.equals("header value1", json.headers.Headeraddedfromtransformer1);
            Assert.equals("header value2", json.headers.Headeraddedfromtransformer2);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }
}

private class AddHeaders implements IHttpRequestTransformer {
    public function new() {
    }

    public function process(request:HttpRequest) {
        if (request.headers == null) {
            request.headers = [];
        }

        request.headers.set("Headeraddedfromtransformer1", "header value1");
        request.headers.set("Headeraddedfromtransformer2", "header value2");
    }
}