package http.server;

#if nodejs

#if http2
typedef HttpServer = http.server.impl.nodejs.Http2Server;
#else
typedef HttpServer = http.server.impl.nodejs.HttpServer;
#end

#else

typedef HttpServer = http.server.impl.fallback.HttpServer;

#end