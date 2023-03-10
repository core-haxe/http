package http;

@:enum
abstract HttpStatus(Int) from Int to Int {
    var Success = 200;
    var NotFound = 404;
    var MethodNotAllowed = 405;
    var InternalServerError = 500;
}
