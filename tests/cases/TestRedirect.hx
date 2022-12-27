package cases;

import haxe.Json;
import http.ContentTypes;
import http.StandardHeaders;
import http.HttpError;
import utest.Assert;
import http.HttpClient;
import utest.Async;
import utest.Test;

@:timeout(10000)
class TestRedirect extends Test {
    private static inline var BASE_URL:String = "https://httpbin.org";

    function setupClass() {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
    }

    function teardownClass() {
        logging.LogManager.instance.clearAdaptors();
    }

    function testRedirect(async:Async) {
        var client = new HttpClient();
        client.get('${BASE_URL}/absolute-redirect/1').then(result -> {
            Assert.notNull(result.response.body);
            var json = result.response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals("http://httpbin.org/get", json.url);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }

    function testRedirect_WithQueryParams(async:Async) {
        var client = new HttpClient();
        client.get('${BASE_URL}/absolute-redirect/1?param1=value1&param2=value2').then(result -> {
            Assert.notNull(result.response.body);
            var json = result.response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals("http://httpbin.org/get?param1=value1&param2=value2", json.url);
            Assert.equals("value1", json.args.param1);
            Assert.equals("value2", json.args.param2);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }

    function testRedirect_WithQueryParamsAlt(async:Async) {
        var client = new HttpClient();
        client.get('${BASE_URL}/absolute-redirect/1', ["param1" => "value1", "param2" => "value2"]).then(result -> {
            Assert.notNull(result.response.body);
            var json = result.response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals("http://httpbin.org/get?param1=value1&param2=value2", json.url);
            Assert.equals("value1", json.args.param1);
            Assert.equals("value2", json.args.param2);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }

    function testRedirect_WithHeaders(async:Async) {
        var client = new HttpClient();
        client.get('${BASE_URL}/absolute-redirect/1', null, ["Header1" => "header value1", "Header2" => "header value2"]).then(result -> {
            Assert.notNull(result.response.body);
            var json = result.response.bodyAsJson;
            Assert.notNull(json);
            Assert.equals("http://httpbin.org/get", json.url);
            Assert.equals("header value1", json.headers.Header1);
            Assert.equals("header value2", json.headers.Header2);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }

    function testRedirect_NoRedirect(async:Async) {
        var client = new HttpClient();
        client.followRedirects = false;
        client.get('${BASE_URL}/absolute-redirect/1').then(result -> {
            Assert.notNull(result.response.body);
            Assert.equals(302, result.response.httpStatus);
            async.done();
        }, (error:HttpError) -> {
            Assert.fail();
            async.done();
        });
    }
}