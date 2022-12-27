# http
flexible http client supporting different http providers

# features
 - Promise based
 - GET, POST, PUT, DELETE http verbs
 - Ability to swap out http providers (via `IHttpProvider`) - currently uses modified versions of Haxe's http
 - Ability to follow redirects
 - Ability to retry failed requests
 - Optional request queue (important when certain apis require requests in order, for example when using nonces)
 - Ability to transform requests / responses (using `IHttpRequestTransformer` or `IHttpResponseTransformer`);
 - Simple, but flexible, interface
 
 # basic usage

### get
```haxe
var client = new HttpClient();
client.followRedirects = false; // defaults to true
client.retryCount = 5; // defaults to 3
client.retryDelayMs = 0; // defaults to 1000
client.defaultRequestHeaders = ["someheader" => "somevalue"];
client.requestTransformers = [new MyRequestTransformerA(), new MyRequestTransformerB()];
client.responseTransformers = [new MyResponseTransformerA(), new MyResponseTransformerB()];
client.get('http://someurl?param1=value1', ["param2" => "value2"], ["header1" => "header value 1"]).then(result -> {
    var foo = result.response.bodyAsJson.bar;
}, (error:HttpError) -> {
    // error
});
```

### post
```haxe
var client = new HttpClient();
client.post('http://someurl?param1=value1', {foo: "bar"}, ["param2" => "value2"], ["header1" => "header value 1"]).then(result -> {
    var foo = result.response.bodyAsJson.bar;
}, (error:HttpError) -> {
    // error
});
```
(all parameters except the url are optional)
