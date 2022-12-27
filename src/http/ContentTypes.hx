package http;

@:enum
abstract ContentTypes(String) from String to String {
    var ApplicationJson = "application/json";
}