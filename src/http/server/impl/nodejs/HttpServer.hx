package http.server.impl.nodejs;

import haxe.io.Bytes;
import haxe.io.Path;
import http.HttpMethod;
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

class HttpServer extends HttpServerBase {
    private var log:Logger = new Logger(HttpServer);

    private var _server:NativeServer;

    public function new() {
        super();
        create();
    }

    public override function start(port:Int) {
        log.info('starting server on port ${port}');
        _server.listen(port);
    }  
   
    private function create() {
        _server = Http.createServer((request, response) -> {
            var data = null;
			request.on('data', (chunk) -> {
                if (data == null) {
                    data = "";
                }
                data += "" + chunk;
				trace('Data chunk available: ${chunk}');
			});
			request.on('end', () -> {
                processRequest(request, response, data);
            });
        });
    }
    
    private function processRequest(nativeRequest:IncomingMessage, nativeResponse:NativeResponse, payload:String) {
        if (_fileDirs != null) {
            var url = Url.fromString(nativeRequest.url);
            for (fileDir in _fileDirs) {
                var filePath = Path.normalize(fileDir + "/" + url.path);
                if (FileSystem.exists(filePath)) {
                    serveFile(filePath, nativeRequest, nativeResponse);
                    return;
                }
            }
        }

        var ip = nativeRequest.socket.remoteAddress;
        log.info('incoming request to "${nativeRequest.url}" from "${ip}"');
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
            if (response.body != null) {
                var buffer = new Uint8Array(response.body.getData(), 0, response.body.length);
                nativeResponse.write(buffer);
            }
            nativeResponse.end();
        }, error -> {
            var httpError:HttpError = null;
            if ((error is HttpError)) {
                httpError = error;
            } else {
                httpError = new HttpError(Std.string(error));
                httpError.httpStatus = HttpStatus.InternalServerError;
                httpError.body = Bytes.ofString(Std.string(error));
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

            nativeResponse.write(buffer);
            nativeResponse.end();
        });
    }

    private function nativeRequestToHttpRequest(nativeRequest:IncomingMessage, payload:String):HttpRequest {
        var url = Url.fromString(nativeRequest.url);
        var request = new HttpRequest(url, dynamicToMap(nativeRequest.headers));
        request.queryParams = url.queryParams;
        switch (Std.string(nativeRequest.method).toLowerCase()) {
            case "get": request.method = HttpMethod.Get;
            case "post": request.method = HttpMethod.Post;
            case "put": request.method = HttpMethod.Put;
            case "patch": request.method = HttpMethod.Patch;
            case "delete": request.method = HttpMethod.Delete;
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