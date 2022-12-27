package http;

@:enum
abstract StandardHeaders(String) from String to String {
    var ContentType = "Content-Type";
}