package http;

class HttpRequestObject {
    public var method:HttpMethod = HttpMethod.Get;
    public var url:Url;
    public var headers:Map<String, Any>;
    public var body:Any;

    public function new(url:Url = null, headers:Map<String, Any> = null) {
        this.url = url;
        this.headers = headers;
    }

    private var _queryParams:Map<String, Any>;
    public var queryParams(get, set):Map<String, Any>;
    private function get_queryParams():Map<String, Any> {
        if (_queryParams == null) {
            _queryParams = [];
        }
        return _queryParams;
    }
    private function set_queryParams(value:Map<String, Any>):Map<String, Any> {
        _queryParams = value;
        return value;
    }

    public function clone():HttpRequest {
        var c = new HttpRequest();
        c.method = this.method;
        c.url = this.url;
        if (this.headers != null) {
            c.headers = this.headers.copy();
        }
        c.body = this.body;
        if (this._queryParams != null) {
            c._queryParams = this._queryParams.copy();
        }
        return c;
    }
}