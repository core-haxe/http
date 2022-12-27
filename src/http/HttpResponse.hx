package http;

import haxe.Json;
import haxe.io.Bytes;

class HttpResponse {
    public var httpStatus:Int;
    public var headers:Map<String, Any>;
    public var body:Bytes;

    public var originalRequest:HttpRequest;

    public function new() {
    }

    public var bodyAsString(get, null):String;
    private function get_bodyAsString():String {
        if (body == null) {
            return null;
        }

        return body.toString();
    }

    public var bodyAsJson(get, null):Dynamic;
    private function get_bodyAsJson():Dynamic {
        if (body == null) {
            return null;
        }

        return Json.parse(body.toString());
    }
}