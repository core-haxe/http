package http;

interface IHttpRequestTransformer {
    function process(request:HttpRequest):Void;
}