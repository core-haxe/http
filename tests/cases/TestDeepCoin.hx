package cases;

import http.HttpMethod;
import http.HttpRequest;
import utest.Assert;
import http.HttpClient;
import utest.Async;

@:timeout(20000)
class TestDeepCoin extends TestBase {
    function setupClass() {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
    }

    function teardownClass() {
        logging.LogManager.instance.clearAdaptors();
    }

    function testBasicNoHeaders(async:Async) {
        var http = new HttpClient();
        var url = new HttpRequest('https://api.deepcoin.com/deepcoin/market/instruments?instType=SPOT');
        url.method = HttpMethod.Get;
        http.makeRequest(url).then(result -> {
            Assert.notNull(result.response.bodyAsJson);
            async.done();
        }, err -> {
            Assert.fail(err);
            trace(err);
            async.done();
        });
    }

    function testBasicWithHeaders(async:Async) {
        var http = new HttpClient();
        var url = new HttpRequest('https://api.deepcoin.com/deepcoin/market/instruments?instType=SPOT');
        url.method = HttpMethod.Get;
        url.headers = ['Host' => 'api.deepcoin.com', 'User-Agent' => 'CustomApp'];
        http.makeRequest(url).then(result -> {
            Assert.notNull(result.response.bodyAsJson);
            async.done();
        }, err -> {
            Assert.fail(err);
            trace(err);
            async.done();
        });
    }
}