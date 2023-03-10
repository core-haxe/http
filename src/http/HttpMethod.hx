package http;

@:enum
abstract HttpMethod(String) from String to String {
    var Get = "get";
    var Post = "post";
    var Put = "put";
    var Patch = "patch";
    var Delete = "delete";
}