package http.server;

typedef HttpServerOptions = {
    @:optional var clustered:Bool;
    @:optional var secure:Bool;
    @:optional var sslPrivateKey:String;
    @:optional var sslPrivateKeyPassword:String;
    @:optional var sslCertificate:String;
    @:optional var sslAllowSelfSignedCertificates:Bool;
}