package cases;

import haxe.io.Bytes;
import http.HttpError;
import http.HttpClient;
import promises.Promise;
import http.server.HttpServer;
import utest.Test;
import utest.Assert;
import utest.Async;

@:timeout(20000)
class TestHttpServer extends Test {
    var port:Int = 9876;
    var httpServer:HttpServer;

    function setupClass() {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));

        httpServer = new HttpServer();
        httpServer.start(port);
    }

    function teardownClass() {
        logging.LogManager.instance.clearAdaptors();
    }

    function testBasic(async:Async) {
        httpServer.onRequest = (httpRequest, httpResponse) -> {
            return new Promise((resolve, reject) -> {
                Assert.equals("/foo/bar", httpRequest.url.path);
                Assert.equals("GET", httpRequest.method);
                httpResponse.write("this is the response");
                resolve(httpResponse);
            });
        };

        var client = new HttpClient();
        client.get('http://localhost:${port}/foo/bar').then(result -> {
            Assert.equals("this is the response", result.response.bodyAsString);
            async.done();
        }, error -> {
            Assert.fail();
        });
    }

    function testParams(async:Async) {
        httpServer.onRequest = (httpRequest, httpResponse) -> {
            return new Promise((resolve, reject) -> {
                Assert.equals("/foo/bar", httpRequest.url.path);
                Assert.equals("GET", httpRequest.method);
                Assert.equals("value1", httpRequest.queryParams.get("param1"));
                Assert.equals("value2", httpRequest.queryParams.get("param2"));
                httpResponse.write("this is the response");
                resolve(httpResponse);
            });
        };

        var client = new HttpClient();
        client.get('http://localhost:${port}/foo/bar?param1=value1&param2=value2').then(result -> {
            Assert.equals("this is the response", result.response.bodyAsString);
            async.done();
        }, error -> {
            Assert.fail();
        });
    }

    function testParamsAlt(async:Async) {
        httpServer.onRequest = (httpRequest, httpResponse) -> {
            return new Promise((resolve, reject) -> {
                Assert.equals("/foo/bar", httpRequest.url.path);
                Assert.equals("GET", httpRequest.method);
                Assert.equals("value1", httpRequest.queryParams.get("param1"));
                Assert.equals("value2", httpRequest.queryParams.get("param2"));
                httpResponse.write("this is the response");
                resolve(httpResponse);
            });
        };

        var client = new HttpClient();
        client.get('http://localhost:${port}/foo/bar', ["param1" => "value1", "param2" => "value2"]).then(result -> {
            Assert.equals("this is the response", result.response.bodyAsString);
            async.done();
        }, error -> {
            Assert.fail();
        });
    }

    function testHeaders(async:Async) {
        httpServer.onRequest = (httpRequest, httpResponse) -> {
            return new Promise((resolve, reject) -> {
                Assert.equals("/foo/bar", httpRequest.url.path);
                Assert.equals("GET", httpRequest.method);
                Assert.equals("header_value1", httpRequest.headers.get("header1"));
                Assert.equals("header_value2", httpRequest.headers.get("header2"));
                httpResponse.write("this is the response");
                resolve(httpResponse);
            });
        };

        var client = new HttpClient();
        client.get('http://localhost:${port}/foo/bar', null, ["header1" => "header_value1", "header2" => "header_value2"]).then(result -> {
            Assert.equals("this is the response", result.response.bodyAsString);
            async.done();
        }, error -> {
            Assert.fail();
        });
    }

    function testBody(async:Async) {
        httpServer.onRequest = (httpRequest, httpResponse) -> {
            return new Promise((resolve, reject) -> {
                Assert.equals("/foo/bar", httpRequest.url.path);
                Assert.equals("POST", httpRequest.method);
                Assert.equals("this is the request body", httpRequest.body);
                httpResponse.write("this is the response");
                resolve(httpResponse);
            });
        };

        var client = new HttpClient();
        client.post('http://localhost:${port}/foo/bar', "this is the request body").then(result -> {
            Assert.equals("this is the response", result.response.bodyAsString);
            async.done();
        }, error -> {
            Assert.fail();
        });
    }

    function testException(async:Async) {
        httpServer.onRequest = (httpRequest, httpResponse) -> {
            return new Promise((resolve, reject) -> {
                Assert.equals("/foo/bar", httpRequest.url.path);
                Assert.equals("GET", httpRequest.method);

                throw "this is an exception";
            });
        };

        var client = new HttpClient();
        client.get('http://localhost:${port}/foo/bar').then(result -> {
            Assert.fail();
            return null;
        }, (error:HttpError) -> {
            Assert.equals("Http Error #500", error.message);
            Assert.equals("this is an exception", error.bodyAsString);
            Assert.equals(500, error.httpStatus);
            async.done();
        });
    }


    function testError(async:Async) {
        httpServer.onRequest = (httpRequest, httpResponse) -> {
            return new Promise((resolve, reject) -> {
                Assert.equals("/foo/bar", httpRequest.url.path);
                Assert.equals("GET", httpRequest.method);

                var httpError = new HttpError("this is the error message", 502);
                httpError.body = Bytes.ofString("this is the error body");
                reject(httpError);
            });
        };

        var client = new HttpClient();
        client.get('http://localhost:${port}/foo/bar').then(result -> {
            Assert.fail();
            return null;
        }, (error:HttpError) -> {
            Assert.equals("Http Error #502", error.message);
            Assert.equals("this is the error body", error.bodyAsString);
            Assert.equals(502, error.httpStatus);
            async.done();
        });
    }
}