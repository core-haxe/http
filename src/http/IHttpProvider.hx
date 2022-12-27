package http;

import promises.Promise;

interface IHttpProvider {
    function makeRequest(request:HttpRequest):Promise<HttpResponse>;
}