package http.server;

#if nodejs

typedef HttpServer = http.server.impl.nodejs.HttpServer;

#else

typedef HttpServer = http.server.impl.fallback.HttpServer;

#end