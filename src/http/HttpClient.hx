package http;

import haxe.Timer;
import http.HttpMethod;
import http.HttpRequest;
import http.providers.DefaultHttpProvider;
import logging.LogManager;
import logging.Logger;
import promises.Promise;
import queues.IQueue;
import queues.IQueue;
import queues.NonQueue;
import queues.NonQueue;
import queues.QueueFactory;

class HttpClient {
    private var log:Logger = new Logger(HttpClient);
    /**
     * Whether to follow http redirects automatically or not
     */
    public var followRedirects:Bool = true;
    /**
     * If a http request fails, try to restablish a connection attempt `x` times
     */
    public var retryCount:Null<Int> = 0;
    /**
     * Add a delay to the retry attempt
     */
    public var retryDelayMs:Int = 1000;
    /**
     * A set of default headers that will be added to all outgoing http requests
     * See the enum `StandardHeaders` for a list of http headers 
     */
    public var defaultRequestHeaders:Map<String, Any>;
    public var requestTransformers:Array<IHttpRequestTransformer>;
    public var responseTransformers:Array<IHttpResponseTransformer>;

    /*
     * Callback that will enable modification of the http request that will be 
     * requeued
     */
    public var onBeforeRedirect:HttpRequest->Void = null;

    public function new() {
    }

    // some queues will want to serialize the data, this means things
    // like functions wont work since they cant be serialized, the 
    // solution is to keep the data (including functions) in a map
    // that we'll look up based on the queue data which, for now
    // will simply be an incrementing int.
    //
    // TODO: is an incrementing int "good enough"?
    private var _nextId:Int = 0;
    private var _idToItem:Map<Int, RequestQueueItem> = [];
    private var _requestQueue:IQueue<Int> = null;
    public var requestQueue(get, set):IQueue<Int>;
    private function get_requestQueue():IQueue<Int> {
        if (_requestQueue != null) {
            return _requestQueue;
        }

        _requestQueue = QueueFactory.instance.createQueue(QueueFactory.NON_QUEUE);
        _requestQueue.onMessage = onQueueMessage;
        return _requestQueue;
    }
    private function set_requestQueue(value:IQueue<Int>):IQueue<Int> {
        _requestQueue = value;
        _requestQueue.onMessage = onQueueMessage;
        return value;
    }

    @:isVar public var encodeUrl(default, set):Bool = true;
    function set_encodeUrl(value) {
        if (_provider != null) {
            _provider.encodeUrl = value;
        }
        return encodeUrl = value;
    }
    
    private var _provider:IHttpProvider = null;
    public var provider(get, set):IHttpProvider;
    private function get_provider():IHttpProvider {
        if (_provider == null) {
            _provider = new DefaultHttpProvider();
		    _provider.encodeUrl = encodeUrl;
        }
        return _provider;
    }
    private function set_provider(value:IHttpProvider):IHttpProvider {
        _provider = value;
        return value;
    }
	/**
	 * Add a header to the default header map
	 * @param header - name of the header
	 * @param value - value of the header
	 */
	public inline function setDefaultRequestHeader(header:String, value:Any) {
		if (this.defaultRequestHeaders == null) {
			this.defaultRequestHeaders = [];
		}
		this.defaultRequestHeaders[header] = value;
	}

	/**
	 * Remove a header from the default header map
	 * @param header - name of the header
	 * @param value - value of the header
	 */
	public inline function removeDefaultRequestHeader(header:String, value:Any) {
		return this.defaultRequestHeaders != null && this.defaultRequestHeaders.remove(header);
	}
    /**
     * Performs a get request 
     * @param request - The url that is being requested
     * @param queryParams - Add any query parameters
     * @param headers - Add any additional headers that should go along with the request, these will be in addition to the headers set on `defaultHeaders`. \nNote headers specified here will take precedent over ones specified as default
     * @return Promise<HttpResponse>
     */
    public inline function get(request:HttpRequest, queryParams:Map<String, Any> = null, headers:Map<String, Any> = null):Promise<HttpResponse> {
        request.method = HttpMethod.Get;
        return makeRequest(request, null, queryParams, headers);
    }
    /**
     * Performs a post request 
     * @param request - The url that is being requested
     * @param queryParams - Add any query parameters
     * @param headers - Add any additional headers that should go along with the request, these will be in addition to the headers set on `defaultHeaders`. \nNote headers specified here will take precedent over ones specified as default
     * @return Promise<HttpResponse>
     */
    public inline function post(request:HttpRequest, body:Any = null, queryParams:Map<String, Any> = null, headers:Map<String, Any> = null):Promise<HttpResponse> {
        request.method = HttpMethod.Post;
        return makeRequest(request, body, queryParams, headers);
    }
    /**
     * Performs a put request
     * @param request - The url that is being requested
     * @param body - Add a data object
     * @param queryParams - Add any query parameters
     * @param headers - Add any additional headers that should go along with the request, these will be in addition to the headers set on `defaultHeaders`. \nNote headers specified here will take precedent over ones specified as default
     * @return Promise<HttpResponse>
     */
    public inline function put(request:HttpRequest, body:Any = null, queryParams:Map<String, Any> = null, headers:Map<String, Any> = null):Promise<HttpResponse> {
        request.method = HttpMethod.Put;
        return makeRequest(request, body, queryParams, headers);
    }
    /**
     * Performs a delete request
     * @param request - The url that is being requested
     * @param body - Add a data object 
     * @param queryParams - Add any query parameters
     * @param headers - Add any additional headers that should go along with the request, these will be in addition to the headers set on `defaultHeaders`. \nNote headers specified here will take precedent over ones specified as default
     * @return Promise<HttpResponse>
     */
    public inline function delete(request:HttpRequest, body:Any = null, queryParams:Map<String, Any> = null, headers:Map<String, Any> = null):Promise<HttpResponse> {
        request.method = HttpMethod.Delete;
        return makeRequest(request, body, queryParams, headers);
    }

    /**
     * Trigger a http request 
     * @param request - The url that is being requested
     * @param body - Add a data object 
     * @param queryParams - Add any query parameters
     * @param headers - Add any additional headers that should go along with the request, these will be in addition to the headers set on `defaultHeaders`. \nNote headers specified here will take precedent over ones specified as default
     * @return Promise<HttpResponse>
     */
    public function makeRequest(request:HttpRequest, body:Any = null, queryParams:Map<String, Any> = null, headers:Map<String, Any> = null):Promise<HttpResponse> {
        var copy = request.clone();

        // query params
        var finalQueryParams:Map<String, Any> = null;
        if (copy.queryParams != null) {
            if (finalQueryParams == null) {
                finalQueryParams = [];
            }
            for (key in copy.queryParams.keys()) {
                finalQueryParams.set(key, copy.queryParams.get(key));
            }
        }
        if (queryParams != null) {
            if (finalQueryParams == null) {
                finalQueryParams = [];
            }
            for (key in queryParams.keys()) {
                finalQueryParams.set(key, queryParams.get(key));
            }
        }
        copy.queryParams = finalQueryParams;

        // headers
        var finalRequestHeaders:Map<String, Any> = defaultRequestHeaders;
        if (copy.headers != null) {
            if (finalRequestHeaders == null) {
                finalRequestHeaders = [];
            }
            for (key in copy.headers.keys()) {
                finalRequestHeaders.set(key, copy.headers.get(key));
            }
        }
        if (headers != null) {
            if (finalRequestHeaders == null) {
                finalRequestHeaders = [];
            }
            for (key in headers.keys()) {
                finalRequestHeaders.set(key, headers.get(key));
            }
        }
        copy.headers = finalRequestHeaders;

        // body
        if (body != null) {
            copy.body = body;
        }

        return new Promise((resolve, reject) -> {
            requestQueue.start().then(_ -> {
                _nextId++;
                _idToItem.set(_nextId, {
                    retryCount: 0,
                    request: copy,
                    resolve: resolve,
                    reject: reject
                });
                requestQueue.enqueue(_nextId);
            }, error -> {
                reject(error);
            });
        });
    }

    private function onQueueMessage(itemId:Int) {
        return new Promise((resolve, reject) -> {
            var item = _idToItem.get(itemId);
            if (item == null) {
                var httpError = new HttpError("could not find request item in map");
                reject(httpError);
                return;
            }
            var request = item.request.clone();
            if (requestTransformers != null) {
                for (transformer in requestTransformers) {
                    transformer.process(request);
                }
            }

            var method:String = request.method;
            log.info('making "${method.toLowerCase()}" request to "${request.url.build()}"');
            if (request.method == HttpMethod.Post && request.headers != null && !request.headers.exists(StandardHeaders.ContentLength)) {
                if (request.body == null) {
                    request.headers.set(StandardHeaders.ContentLength, 0);
                } else if (request.body is String) {
                    var stringBody:String = request.body;
                    request.headers.set(StandardHeaders.ContentLength, stringBody.length);
                } else if (request.body is haxe.io.Bytes) {
                    var bytesBody:haxe.io.Bytes = request.body;
                    request.headers.set(StandardHeaders.ContentLength, bytesBody.length);
                } else {
                    request.headers.set(StandardHeaders.ContentLength, Std.string(request.body).length);
                }
            }

            provider.makeRequest(request).then(response -> {
                if (response != null) {
                    if (LogManager.instance.shouldLogDebug) {
                        log.debug('response received: ');
                        log.debug('    headers:', response.headers);
                        log.debug('    body:', response.bodyAsString);
                    } else {
                        log.info('response received (${response.httpStatus})');
                    }
                } else {
                    if (LogManager.instance.shouldLogWarnings) {
                        log.warn('null response received');
                    }
                }
                
                if (responseTransformers != null) {
                    for (transformer in responseTransformers) {
                        transformer.process(response);
                    }
                }
    
                // handle redirections by requeing the request with the new url
                if (followRedirects && (response.httpStatus == 301 || response.httpStatus == 302)) {
                    var redirectLocation:String = null;
                    if (response.headers != null) {
                        redirectLocation = response.headers.get("location");
                        if (redirectLocation == null) {
                            redirectLocation = response.headers.get("Location");
                        }
                    }

                    var url:Url = Url.fromString(redirectLocation);
                    /* possibly ill conceived - should redirect location be taken "as is" and lose any params / headers on original request?
                    var redirectQueryParams:Map<String, Any> = [];
                    if (url.queryParams != null) {
                        redirectQueryParams = url.queryParams.copy();
                    }
                    redirectQueryParams.remove("location");
                    redirectQueryParams.remove("Location");
                    */

                    // we'll consider it an error if there is no location header
                    if (redirectLocation == null) {
                        log.error('redirect encountered (${response.httpStatus}), no location header found');
                        var httpError = new HttpError("no location header found", response.httpStatus);
                        httpError.body = response.body;
                        httpError.headers = response.headers;
                        _idToItem.remove(itemId);
                        item.reject(httpError);
                        resolve(true); // ack
                        return;
                    }

                    /* possibly ill conceived - should redirect location be taken "as is" and lose any params / headers on original request?
                    var queryParams = item.request.url.queryParams; // cache original queryParams from url
                    for (k in redirectQueryParams.keys()) {
                        if (queryParams == null) {
                            queryParams = [];
                        }                    
                        queryParams.set(k, redirectQueryParams.get(k));
                    }
                    item.request.url.queryParams = queryParams;
                    */
                    item.request.url = redirectLocation;
                    item.retryCount = 0;
                    if (onBeforeRedirect != null) {
                        onBeforeRedirect(item.request);
                    }
                    requestQueue.requeue(itemId);
                    resolve(true); // ack
                    return;
                }

                _idToItem.remove(itemId);
                item.resolve(response);
                resolve(true); // ack
            }, (error:HttpError) -> {
                if (retryCount == null) {
                    log.error('request failed (${error.httpStatus})');
                    error.retryCount = 0;
                    _idToItem.remove(itemId);
                    item.reject(error); 
                } else {
                    item.retryCount++;
                    if (item.retryCount > retryCount) {
                        if (retryCount > 0) {
                            log.error('request failed (${error.httpStatus}), retries exhausted');
                            error.retryCount = item.retryCount - 1;
                        } else {
                            log.error('request failed (${error.httpStatus})');
                            error.retryCount = 0;
                        }
                        _idToItem.remove(itemId);
                        item.reject(error); 
                    } else {
                        log.error('request failed (${error.httpStatus}), retrying (${item.retryCount} of ${retryCount})');
                        requestQueue.requeue(itemId, retryDelayMs);
                    }
                }
                resolve(true); // we are resolving true even though its an error as this is to tell the queue we have processed the message (ie, ack)
            });
        });
    }
}

typedef RequestQueueItem = {
    var retryCount:Int;
    var request:HttpRequest;
    var resolve:HttpResponse->Void;
    var reject:Dynamic->Void;
}
