package http;

import haxe.io.Bytes;
import haxe.Json;

class HttpError {
    public var retryCount:Int = 0;
    public var message:String;
    public var httpStatus:Null<Int>;
    public var body:Bytes = null;
    public var headers:Map<String, Any>;

    public function new(message:String, httpStatus:Null<Int> = null) {
        this.message = message;
        this.httpStatus = httpStatus;
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