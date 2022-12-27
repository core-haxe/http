package http;

class HttpResult {
    public var client:HttpClient;
    public var response:HttpResponse;

    public function new(client:HttpClient, response:HttpResponse = null) {
        this.client = client;
        this.response = response;
    }
}