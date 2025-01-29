package http.server.impl.nodejs;

import js.node.Buffer;
import haxe.io.Bytes;
import js.Node;
import sys.FileSystem;
import haxe.io.Path;
import js.node.Fs;
import js.lib.Uint8Array;
import js.lib.Error;

using StringTools;

class Http2Server extends HttpServerCommon {
    public function new(options:HttpServerOptions = null) {
        super(options);
        if (options != null && options.sslAllowSelfSignedCertificates) {
            // for self signed certs
            Sys.putEnv("NODE_TLS_REJECT_UNAUTHORIZED", "0");
        }
        create();
    }

    /*
    private function create() {
        if (!options.clustered) {
            createServer();
        } else {
            if (js.node.Cluster.instance.isMaster) {
                var numCPUs = js.node.Os.cpus().length;
                for (i in 0...numCPUs) {
                    js.node.Cluster.instance.fork();
                }
            } else {
                createServer();
            }
        }
    }
    */

    private var server:Dynamic;
    private override function createServer() {
        var http2 = Node.require("node:http2");
        server = http2.createSecureServer({
            key: options.sslPrivateKey,
            cert: options.sslCertificate,
            passphrase: options.sslPrivateKeyPassword
        });

        server.on('error', (err) -> trace(err));

        server.on('stream', (stream:Dynamic, headers:Dynamic) -> {
            var chunks = [];
            stream.on('data', function(chunk) {
                chunks.push(chunk);
            });

            stream.on('end', function() {
                var body = Buffer.concat(chunks);
                chunks = [];

                // stream is a Duplex
                processRequest(stream, headers, body.toString());
                /*
                if (response != null) {
                    var nativeHeaders:Dynamic = {};
                    if (response.headers != null) {
                        for (key in response.headers.keys()) {
                            Reflect.setField(nativeHeaders, key, response.headers.get(key));
                        }
                    }
                    stream.respond(nativeHeaders);
                    if (response.payload != null) {
                        stream.end(response.payload);
                    } else {
                        stream.end();
                    }
                }
                */    

                /*
                stream.respond({
                    'content-type': 'text/html; charset=utf-8',
                    ':status': 200,
                });
                stream.end('<h1>Hello World</h1>');
                */
            });
        });
        
        /*
        if (options.secure) {
            var serverOptions:HttpsCreateServerOptions = {
                key: options.sslPrivateKey,
                cert: options.sslCertificate,
                passphrase: options.sslPrivateKeyPassword
            }
            _secureServer = Https.createServer(serverOptions, (request, response) -> {
                var data = null;
                request.on('data', (chunk) -> {
                    if (data == null) {
                        data = "";
                    }
                    data += "" + chunk;
                });
                request.on('end', () -> {
                    processRequest(request, response, data);
                });
            });
        } else {
            _server = Http.createServer((request, response) -> {
                var data = null;
                request.on('data', (chunk) -> {
                    if (data == null) {
                        data = "";
                    }
                    data += "" + chunk;
                });
                request.on('end', () -> {
                    processRequest(request, response, data);
                });
            });
        }
        */    
    }

    private function processRequest(stream:Dynamic, headers:Dynamic, payload:String):Void {
        if (_fileDirs != null && _fileDirs.length != 0) {
            for (fileDir in _fileDirs) {
                var urlPath:String = Reflect.field(headers, ":path");
                urlPath = urlPath.urlDecode();
                if (urlPath == "/") {
                    urlPath = "/index.html";
                }
                if (urlPath.startsWith(fileDir.prefix)) {
                    var relativePath = urlPath.replace(fileDir.prefix, "");
                    var filePath = Path.normalize(fileDir.dir + "/" + relativePath);
                    if (FileSystem.exists(filePath)) {
                        serveFile(filePath, stream, headers);
                        return;
                    }
                }
            }
        }

        /*
        var ip = nativeRequest.socket.remoteAddress;
        log.info('incoming ${nativeRequest.method} request to "${nativeRequest.url}" from "${ip}"');
        if (LogManager.instance.shouldLogData) {
            log.data('headers', nativeRequest.headers);
            if (payload != null) {
                log.data('payload', payload);
            }
        }
        */
        
        if (onRequest == null) {
            //nativeResponse.statusCode = HttpStatus.NotFound;
            //nativeResponse.end();
            //return { headers: [':status' => HttpStatus.NotFound] } ;
            stream.respond({
                ':status': HttpStatus.NotFound
            });
            stream.end();
            return;
        }
        
        var request = nativeRequestToHttpRequest(stream, headers, payload);
        var response = new HttpResponse();
        response.httpStatus = HttpStatus.Success;
        response.headers = [];
        response.headers.set(StandardHeaders.ContentType, ContentTypes.TextPlain);
        var nativeResponse2:{headers:Map<String, Any>, payload:Any} = { headers: [], payload: null};
        onRequest(request, response).then(response -> {
            //nativeResponse.statusCode = response.httpStatus;
            nativeResponse2.headers.set(":status", response.httpStatus);
            if (response.headers != null) {
                for (k in response.headers.keys()) {
                    var v = response.headers.get(k);
                    //nativeResponse.setHeader(k, v);
                    nativeResponse2.headers.set(k, v);
                }
            }
            // TODO: make optional and restricted
            /*
            nativeResponse.setHeader("Access-Control-Allow-Origin", "*");
            nativeResponse.setHeader("Access-Control-Allow-Headers", "*");
            */
            nativeResponse2.headers.set("Access-Control-Allow-Origin", "*");
            nativeResponse2.headers.set("Access-Control-Allow-Headers", "*");
            if (response.body != null) {
                var buffer = new Uint8Array(response.body.getData(), 0, response.body.length);
                nativeResponse2.payload = buffer;
            }
            /*
            if (response.body != null) {
                var buffer = new Uint8Array(response.body.getData(), 0, response.body.length);
                nativeResponse.write(buffer);
            }
            nativeResponse.end();
            */

            var nativeHeaders:Dynamic = {};
            if (nativeResponse2.headers != null) {
                for (key in nativeResponse2.headers.keys()) {
                    Reflect.setField(nativeHeaders, key, nativeResponse2.headers.get(key));
                }
            }
            stream.respond(nativeHeaders);
            if (nativeResponse2.payload != null) {
                stream.end(nativeResponse2.payload);
            } else {
                stream.end();
            }


        }, error -> {
            var httpError:HttpError = null;
            if ((error is HttpError)) {
                httpError = error;
            } else if (error is Error) {
                var jsError:Error = cast(error, Error);
                httpError = new HttpError(jsError.message, HttpStatus.InternalServerError);
                httpError.body = Bytes.ofString(jsError.message);
            } else {
                httpError = new HttpError(Std.string(error));
                httpError.httpStatus = HttpStatus.InternalServerError;
                httpError.body = Bytes.ofString(Std.string(error));
            }

            if (httpError == null) {
                httpError = new HttpError("unknown error encountered", HttpStatus.InternalServerError);
            }

            // TODO: make optional and restricted
            /*
            nativeResponse.setHeader("Access-Control-Allow-Origin", "*");
            nativeResponse.setHeader("Access-Control-Allow-Headers", "*");
            */
            nativeResponse2.headers.set("Access-Control-Allow-Origin", "*");
            nativeResponse2.headers.set("Access-Control-Allow-Headers", "*");

            if (httpError.headers != null) {
                for (key in httpError.headers.keys()) {
                    //nativeResponse.setHeader(key, httpError.headers.get(key));
                    nativeResponse2.headers.set(key, httpError.headers.get(key));
                }
            }

            //nativeResponse.statusCode = httpError.httpStatus;
            nativeResponse2.headers.set(":status", httpError.httpStatus);
            if (httpError.body != null) {
                var buffer = new Uint8Array(httpError.body.getData(), 0, httpError.body.length);
                nativeResponse2.payload = buffer;
                //nativeResponse.write(buffer);

            }
            //nativeResponse.end();

            var nativeHeaders:Dynamic = {};
            if (nativeResponse2.headers != null) {
                for (key in nativeResponse2.headers.keys()) {
                    Reflect.setField(nativeHeaders, key, nativeResponse2.headers.get(key));
                }
            }
            stream.respond(nativeHeaders);
            if (nativeResponse2.payload != null) {
                stream.end(nativeResponse2.payload);
            } else {
                stream.end();
            }

        });
    }

    private function nativeRequestToHttpRequest(stream:Dynamic, headers:Dynamic, payload:String):HttpRequest {
        var urlPath:String = Reflect.field(headers, ":path");
        var url = Url.fromString(urlPath);
        var request = new HttpRequest(url, dynamicToMap(headers));
        request.queryParams = url.queryParams;
        //request.remoteAddress = nativeRequest.socket.remoteAddress;
        switch (Std.string(Reflect.field(headers, ":method")).toLowerCase()) {
            case "get": request.method = HttpMethod.Get;
            case "post": request.method = HttpMethod.Post;
            case "put": request.method = HttpMethod.Put;
            case "patch": request.method = HttpMethod.Patch;
            case "delete": request.method = HttpMethod.Delete;
            case "options": request.method = HttpMethod.Options;
        }
        request.body = payload;
        return request;
    }

    private function dynamicToMap(o:Dynamic):Map<String, Any> {
        var map:Map<String, Any> = [];
        for (f in Reflect.fields(o)) {
            map.set(f, Reflect.field(o, f));
        }
        return map;
    }

    private function serveFile(filePath:String, stream:Dynamic, headers:Dynamic) {
        Fs.readFile(filePath, (error, buffer) -> {
            if (error != null) {
                return;
            }

            // TODO: make optional and restricted
            stream.respond({
                ':status': 200,
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': '*'
            }); 
            stream.end(buffer);
        });
    }

    public override function start(port:Int) {
        trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>> L", port);
        server.listen(port);
    }
}