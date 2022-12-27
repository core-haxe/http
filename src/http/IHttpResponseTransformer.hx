package http;

interface IHttpResponseTransformer {
    function process(response:HttpResponse):Void;
}