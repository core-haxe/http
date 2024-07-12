package http.server.impl.nodejs;

import haxe.io.Bytes;
import haxe.io.Path;
import http.HttpMethod;
import js.lib.Error;
import js.lib.Uint8Array;
import js.node.Fs;
import js.node.Http;
import js.node.http.IncomingMessage;
import js.node.http.Server as NativeServer;
import js.node.http.ServerResponse as NativeResponse;
import logging.LogManager;
import logging.Logger;
import promises.Promise;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class HttpServer extends HttpServerBase {
    private var log:Logger = new Logger(HttpServer);

    private var _server:NativeServer;

    public function new(clustered:Bool = false) {
        super(clustered);
        create();
    }

    public override function start(port:Int) {
        log.info('starting server on port ${port}');
        if (!clustered) {
            _server.listen(port);
        } else {
            if (!js.node.Cluster.instance.isMaster) { 
                _server.listen(port);
            }
        }
    }  
   
    private function create() {
        if (!clustered) {
            createServer();
        } else {
            if (js.node.Cluster.instance.isMaster) {
                /*
                js.node.Cluster.instance.setupMaster({
                    windowsHide: true
                });
                */
                var numCPUs = js.node.Os.cpus().length;
                for (i in 0...numCPUs) {
                    js.node.Cluster.instance.fork();
                }
            } else {
                createServer();
            }
        }
    }

    private function createServer() {
        _server = Http.createServer((request, response) -> {
            var data = null;
            request.on('data', (chunk) -> {
                if (data == null) {
                    data = "";
                }
                data += "" + chunk;
            });
            request.on('end', () -> {
                processRequest(request, response, data);
            });
        });
    }
    
    private function processRequest(nativeRequest:IncomingMessage, nativeResponse:NativeResponse, payload:String) {
        if (_fileDirs != null && _fileDirs.length != 0) {
            var url = Url.fromString(nativeRequest.url);
            for (fileDir in _fileDirs) {
                var urlPath = url.path;
                urlPath = urlPath.urlDecode();
                if (urlPath == "/") {
                    urlPath = "/index.html";
                }
                if (urlPath.startsWith(fileDir.prefix)) {
                    var relativePath = urlPath.replace(fileDir.prefix, "");
                    var filePath = Path.normalize(fileDir.dir + "/" + relativePath);
                    if (FileSystem.exists(filePath)) {
                        serveFile(filePath, nativeRequest, nativeResponse);
                        return;
                    }
                }
            }
        }

        var ip = nativeRequest.socket.remoteAddress;
        log.info('incoming ${nativeRequest.method} request to "${nativeRequest.url}" from "${ip}"');
        if (LogManager.instance.shouldLogData) {
            log.data('headers', nativeRequest.headers);
            if (payload != null) {
                log.data('payload', payload);
            }
        }

        if (onRequest == null) {
            nativeResponse.statusCode = HttpStatus.NotFound;
            nativeResponse.end();
            return;
        }

        var request = nativeRequestToHttpRequest(nativeRequest, payload);
        var response = new HttpResponse();
        response.httpStatus = HttpStatus.Success;
        response.headers = [];
        response.headers.set(StandardHeaders.ContentType, ContentTypes.TextPlain);
        onRequest(request, response).then(response -> {
            nativeResponse.statusCode = response.httpStatus;
            if (response.headers != null) {
                for (k in response.headers.keys()) {
                    var v = response.headers.get(k);
                    nativeResponse.setHeader(k, v);
                }
            }
            // TODO: make optional and restricted
            nativeResponse.setHeader("Access-Control-Allow-Origin", "*");
            nativeResponse.setHeader("Access-Control-Allow-Headers", "*");
            if (response.body != null) {
                var buffer = new Uint8Array(response.body.getData(), 0, response.body.length);
                nativeResponse.write(buffer);
            }
            nativeResponse.end();
        }, error -> {
            var httpError:HttpError = null;
            if ((error is HttpError)) {
                httpError = error;
            } else if (error is Error) {
                var jsError:Error = cast(error, Error);
                httpError = new HttpError(jsError.message, HttpStatus.InternalServerError);
                httpError.body = Bytes.ofString(jsError.message);
            } else {
                httpError = new HttpError(Std.string(error));
                httpError.httpStatus = HttpStatus.InternalServerError;
                httpError.body = Bytes.ofString(Std.string(error));
            }

            if (httpError == null) {
                httpError = new HttpError("unknown error encountered", HttpStatus.InternalServerError);
            }

            // TODO: make optional and restricted
            nativeResponse.setHeader("Access-Control-Allow-Origin", "*");
            nativeResponse.setHeader("Access-Control-Allow-Headers", "*");
            if (httpError.headers != null) {
                for (key in httpError.headers.keys()) {
                    nativeResponse.setHeader(key, httpError.headers.get(key));
                }
            }

            nativeResponse.statusCode = httpError.httpStatus;
            if (httpError.body != null) {
                var buffer = new Uint8Array(httpError.body.getData(), 0, httpError.body.length);
                nativeResponse.write(buffer);
            }
            nativeResponse.end();
        });
    }

    private function serveFile(filePath:String, nativeRequest:IncomingMessage, nativeResponse:NativeResponse) {
        log.info('serving file "${filePath}"');
        Fs.readFile(filePath, (error, buffer) -> {
            if (error != null) {
                return;
            }

            // TODO: make optional and restricted
            nativeResponse.setHeader("Access-Control-Allow-Origin", "*");
            nativeResponse.setHeader("Access-Control-Allow-Headers", "*");

            nativeResponse.write(buffer);
            nativeResponse.end();
        });
    }

    private function nativeRequestToHttpRequest(nativeRequest:IncomingMessage, payload:String):HttpRequest {
        var url = Url.fromString(nativeRequest.url);
        var request = new HttpRequest(url, dynamicToMap(nativeRequest.headers));
        request.queryParams = url.queryParams;
        request.remoteAddress = nativeRequest.socket.remoteAddress;
        switch (Std.string(nativeRequest.method).toLowerCase()) {
            case "get": request.method = HttpMethod.Get;
            case "post": request.method = HttpMethod.Post;
            case "put": request.method = HttpMethod.Put;
            case "patch": request.method = HttpMethod.Patch;
            case "delete": request.method = HttpMethod.Delete;
            case "options": request.method = HttpMethod.Options;
        }
        request.body = payload;
        return request;
    }

    private function dynamicToMap(o:Dynamic):Map<String, Any> {
        var map:Map<String, Any> = [];
        for (f in Reflect.fields(o)) {
            map.set(f, Reflect.field(o, f));
        }
        return map;
    }
}
