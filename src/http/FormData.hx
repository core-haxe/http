package http;

#if nodejs

typedef FormData = http.impl.nodejs.FormData;

#else

typedef FormData = http.impl.fallback.FormData;

#end