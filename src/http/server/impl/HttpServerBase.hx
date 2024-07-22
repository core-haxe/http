package http.server.impl;

import haxe.display.JsonModuleTypes.JsonTypePathWithParams;
import haxe.io.Path;
import logging.LogManager;
import logging.Logger;
import promises.Promise;

class HttpServerBase {
    private var baseLog:Logger = new Logger(HttpServerBase);

    public var onRequest:HttpRequest->HttpResponse->Promise<HttpResponse> = null;

    private var _fileDirs:Array<FileDir> = null;

    private var options:HttpServerOptions = {};

    public function new(options:HttpServerOptions = null) {
        this.options = options;
        if (this.options == null) {
            this.options = {};
        }
    }

    public function start(port:Int) {
    }

    public function stop() {
    }

    public function serveFilesFrom(prefix:String, dir:String) {
        if (_fileDirs == null) {
            _fileDirs = [];
        }
        var dir = Path.normalize(Sys.getCwd() + "/" + dir);
        baseLog.info('serving static resources from "${dir}"');
        _fileDirs.push({
            prefix: prefix,
            dir: dir
        });
    }
}

typedef FileDir = {
    var prefix:String;
    var dir:String;
}
