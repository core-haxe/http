package http.server.impl.nodejs;

class HttpServerCommon extends HttpServerBase {
    private function create() {
        if (!options.clustered) {
            createServer();
        } else {
            if (js.node.Cluster.instance.isMaster) {
                /*
                js.node.Cluster.instance.setupMaster({
                    windowsHide: true
                });
                */
                var numCPUs = js.node.Os.cpus().length;
                for (i in 0...numCPUs) {
                    js.node.Cluster.instance.fork();
                }
            } else {
                createServer();
            }
        }
    }

    private function createServer() {

    }
}