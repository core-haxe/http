package http;

enum abstract ContentTypes(String) from String to String {
    var ApplicationJson = "application/json";
    var TextPlain = "text/pain";
    var FormUrlEncoded = "application/x-www-form-urlencoded";
}