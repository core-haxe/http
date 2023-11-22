package http;

enum abstract HttpMethod(String) from String to String {
	var Get = "GET";
	var Post = "POST";
	var Put = "PUT";
	var Patch = "PATCH";
	var Delete = "DELETE";
	var Options = "OPTIONS";
}
