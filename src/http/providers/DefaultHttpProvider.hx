package http.providers;

import haxe.Http;
import haxe.Json;
import haxe.io.Bytes;
import logging.LogManager;
import logging.Logger;
import promises.Promise;

#if target.threaded

private typedef ThreadInfo = {
    var resolve:HttpResponse->Void;
    var reject:Any->Void;
    var ?response:HttpResponse;
    var ?error:Any;
}
#end

class DefaultHttpProvider implements IHttpProvider {
    private var log:Logger = new Logger(DefaultHttpProvider);

    public function new() {
    }

    #if target.threaded
    private static var _nextId:Int = 0;
    private static var _map:Map<Int, ThreadInfo> = [];
    private static var _ready:Array<ThreadInfo> = [];
    private static var mutex:sys.thread.Mutex = new sys.thread.Mutex();

    // basic threaded request, which allows for async programming, could / should be greatly 
    // improved by using a thread pool, but for a preliminary impl its better than the
    // standard (sync) behaviour of haxe std http
    private function makeThreadedRequest(request:HttpRequest):Promise<HttpResponse> {
        return new Promise((resolve, reject) -> {
            mutex.acquire();
            var currentId = _nextId;
            _map.set(currentId, {
                resolve: resolve,
                reject: reject
            });
            _nextId++;
            mutex.release();

            var thread = sys.thread.Thread.createWithEventLoop(() -> {
                makeRequestCommon(request).then(response -> {
                    complete(currentId, response);
                }, error -> {
                    errored(currentId, error);
                });
            });
        });
    }

    private static function complete(id:Int, response:HttpResponse) {
        mutex.acquire();
        var item = _map.get(id);
        item.response = response;
        _map.remove(id);
        _ready.push(item);
        mutex.release();
    }   
    
    private static function errored(id:Int, error:Any) {
        mutex.acquire();
        var item = _map.get(id);
        item.error = error;
        _map.remove(id);
        _ready.push(item);
        mutex.release();
    }

    private static function onTimer() {
        var ready = [];
        mutex.acquire();
        while (_ready.length > 0) {
            var item = _ready.shift();
            ready.push(item); // lets not hold the mutex for any longer than we need to, we'll process them later
        }
        mutex.release();

        for (item in ready) {
            if (item.response != null) {
                item.resolve(item.response);
            } else if (item.error != null) {
                item.reject(item.error);
            }
        }
    }

    private static var _timer:haxe.Timer = null;
    #end

    public function makeRequest(request:HttpRequest):Promise<HttpResponse> {
        #if target.threaded
        if (_timer == null) {
            _timer = new haxe.Timer(10);
            _timer.run = onTimer;
        }
        #end
        
        #if target.threaded
        return makeThreadedRequest(request);
        #else
        return makeRequestCommon(request);
        #end
    }

    private function makeRequestCommon(request:HttpRequest):Promise<HttpResponse> {
        return new Promise((resolve, reject) -> {
            var url = request.url.build(false);
            var http = new Http(url);
            var response = new HttpResponse();
            response.originalRequest = request;

            // add any params from the url query
            var allParameters:Map<String, Any> = [];
            for (queryParamKey in request.url.queryParams.keys()) {
                allParameters.set(queryParamKey, request.url.queryParams.get(queryParamKey));
            }
            // lets also add (and overwrite) any params that come from the actual request
            for (queryParamKey in request.queryParams.keys()) {
                allParameters.set(queryParamKey, request.queryParams.get(queryParamKey));
            }
            // finally lets add them to the actual request
            for (queryParamKey in allParameters.keys()) {
                http.addParameter(queryParamKey, allParameters.get(queryParamKey));
            }

            // add headers
            if (request.headers != null) {
                for (headerKey in request.headers.keys()) {
                    http.addHeader(headerKey, request.headers.get(headerKey));
                }
            }

            // log some info (only if a log adapator will respond to debug)
            if (LogManager.instance.shouldLogDebug) {
                var method:String = request.method;
                log.debug('making "${method.toLowerCase()}" request to "${url}"');
                log.debug('    headers:', request.headers);
                log.debug('    query params:', allParameters);
                if (request.body != null) {
                    log.debug('    body:', request.body);
                }
            }

            #if sys
            var output = new haxe.io.BytesOutput();
            #end
            http.onBytes = (bytes:Bytes) -> {
                response.headers = http.responseHeaders;
                response.body = bytes;
                resolve(response);
            }
            /*
            http.onData = (data:String) -> {
                trace("onData", data.length);
            }
            */
            http.onStatus = (status:Int) -> {
                response.httpStatus = status;
            }
            http.onError = (msg:String) -> {
                trace(">>>>>>>>>>>>>>>>>>>>>>>>>> HTTP ERROR", msg);
                var httpError = new HttpError(msg, response.httpStatus);
                if (http.responseBytes != null) {
                    httpError.body = http.responseBytes;
                }
                if (http.responseHeaders != null) {
                    httpError.headers = http.responseHeaders;
                }
                reject(httpError);
            }

            var body:Any = request.body;
            if (body != null) {
                if (request.headers != null) {
                    var contentType = request.headers.get(StandardHeaders.ContentType);
                    if (contentType == ContentTypes.ApplicationJson) {
                        if (!(body is String)) {
                            body = Json.stringify(body);
                        }
                    }
                }

                if ((body is String)) {
                    http.setPostData(body);
                } else if ((body is Bytes)) {
                    http.setPostBytes(body);
                } else {
                    http.setPostData(Std.string(body));
                }
            }

            switch (request.method) {
                case Get:
                    http.request();
                case Post:
                    http.request(true);
                case Put:
                    #if sys

                    http.customRequest(true, output, null, "PUT");

                    #else

                    http.customRequest(true, "PUT");    
                    http.request(true);

                    #end
                case Delete:
                    #if sys

                    http.customRequest(true, output, null, "DELETE");

                    #else

                    http.customRequest(true, "DELETE");    
                    http.request(true);

                    #end
                case _:
                    throw new HttpError("http method not implemented (" + request.method + ")");
            }
        });
    }
}