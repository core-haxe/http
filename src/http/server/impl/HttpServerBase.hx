package http.server.impl;

import haxe.display.JsonModuleTypes.JsonTypePathWithParams;
import haxe.io.Path;
import logging.LogManager;
import logging.Logger;
import promises.Promise;

class HttpServerBase {
    private var baseLog:Logger = new Logger(HttpServerBase);

    public var onRequest:HttpRequest->HttpResponse->Promise<HttpResponse> = null;

    private var _fileDirs:Array<String> = null;

    public function new() {
    }

    public function start(port:Int) {
    }

    public function serveFilesFrom(dir:String) {
        if (_fileDirs == null) {
            _fileDirs = [];
        }
        var dir = Path.normalize(Sys.getCwd() + "/" + dir);
        baseLog.info('serving static resources from "${dir}"');
        _fileDirs.push(dir);
    }
}