package http;

import promises.Promise;

interface IHttpProvider {
    public var encodeUrl:Bool;
    function makeRequest(request:HttpRequest):Promise<HttpResponse>;
}
