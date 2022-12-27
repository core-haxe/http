package http;

@:forward
@:forward.new
abstract HttpRequest(HttpRequestObject) {
    @:from public static function fromString(s:String):HttpRequest {
        return new HttpRequest(s);
    }
}