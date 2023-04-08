package http.providers;

import haxe.Http;
import haxe.Json;
import haxe.io.Bytes;
import logging.LogManager;
import logging.Logger;
import promises.Promise;

#if sys
private typedef ThreadInfo = {
    var request:HttpRequest;
    var resolve:HttpResponse->Void;
    var reject:Any->Void;
}
#end

class DefaultHttpProvider implements IHttpProvider {
    private var log:Logger = new Logger(DefaultHttpProvider);

    public function new() {
    }

    #if sys
    // basic threaded request, which allows for async programming, could / should be greatly 
    // improved by using a thread pool, but for a preliminary impl its better than the
    // standard (sync) behaviour of haxe std http
    private function makeThreadedRequest(request:HttpRequest):Promise<HttpResponse> {
        return new Promise((resolve, reject) -> {
            var thread = sys.thread.Thread.createWithEventLoop(() -> {
                var info:ThreadInfo = sys.thread.Thread.readMessage(true);
                makeRequestCommon(info.request).then(result -> {
                    info.resolve(result);
                }, error -> {
                    info.reject(error);
                });
            });
            thread.sendMessage({
                request: request,
                resolve: resolve,
                reject: reject
            });
        });
    }
    #end

    public function makeRequest(request:HttpRequest):Promise<HttpResponse> {
        #if sys
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