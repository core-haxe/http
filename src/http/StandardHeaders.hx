package http;

@:enum
abstract StandardHeaders(String) from String to String {
	// Acceptable instance-manipulations for the request.
	var AIM = "A-IM";
	// Media type(s) that is/are acceptable for the response. See Content negotiation.
	var Accept = "Accept";
	// Character sets that are acceptable.
	var AcceptCharset = "Accept-Charset";
	// Acceptable version in time.
	var AcceptDatetime = "Accept-Datetime";
	// List of acceptable encodings. See HTTP compression.
	var AcceptEncoding = "Accept-Encoding";
	// List of acceptable human languages for response. See Content negotiation.
	var AcceptLanguage = "Accept-Language";
	// Initiates a request for cross-origin resource sharing with Origin (below).
	var AccessControlRequestMethod = "Access-Control-Request-Method";
	// Initiates a request for cross-origin resource sharing with Origin (below).
	var AccessControlRequestHeaders = "Access-Control-Request-Headers";
	// Authentication credentials for HTTP authentication.
	var Authorization = "Authorization";
	// Used to specify directives that must be obeyed by all caching mechanisms along the request-response chain.
	var CacheControl = "Cache-Control";
	// Control options for the current connection and list of hop-by-hop request fields. Must not be used with HTTP/2.
	var Connection = "Connection";
	// The type of encoding used on the data. See HTTP compression.
	var ContentEncoding = "Content-Encoding";
	// The length of the request body in octets (8-bit bytes).
	var ContentLength = "Content-Length";
	// A Base64-encoded binary MD5 sum of the content of the request body.
	var ContentMD5 = "Content-MD5";
	// The Media type of the body of the request (used with POST and PUT requests).
	var ContentType = "Content-Type";
	// An HTTP cookie previously sent by the server with Set-Cookie (below).
	var Cookie = "Cookie";
	// The date and time at which the message was originated (in "HTTP-date" format as defined by RFC 9110: HTTP Semantics, section 5.6.7 "Date/Time Formats").
	var Date = "Date";
	// Indicates that particular server behaviors are required by the client.
	var Expect = "Expect";
	// Disclose original information of a client connecting to a web server through an HTTP proxy.
	var Forwarded = "Forwarded";
	// The email address of the user making the request.
	var From = "From";

	/**
	 * The domain name of the server (for virtual hosting), and the TCP port number on which the server is listening. The port number may be omitted if the port is the standard port for the service requested.
	 * Mandatory since HTTP/1.1.
	 * If the request is generated directly in HTTP/2, it should not be used.
	**/
	var Host = "Host";

	// A request that upgrades from HTTP/1.1 to HTTP/2 MUST include exactly one HTTP2-Setting header field. The HTTP2-Settings header field is a connection-specific header field that includes parameters that govern the HTTP/2 connection, provided in anticipation of the server accepting the request to upgrade.
	var HTTP2Settings = "HTTP2-Settings";
	// Only perform the action if the client supplied entity matches the same entity on the server. This is mainly for methods like PUT to only update a resource if it has not been modified since the user last updated it.
	var IfMatch = "If-Match";
	// Allows a 304 Not Modified to be returned if content is unchanged.
	var IfModifiedSince = "If-Modified-Since";
	// Allows a 304 Not Modified to be returned if content is unchanged, see HTTP ETag.
	var IfNoneMatch = "If-None-Match";
	// If the entity is unchanged, send me the part(s) that I am missing; otherwise, send me the entire new entity.
	var IfRange = "If-Range";
	// Only send the response if the entity has not been modified since a specific time.
	var IfUnmodifiedSince = "If-Unmodified-Since";
	// Limit the number of times the message can be forwarded through proxies or gateways.
	var MaxForwards = "Max-Forwards";
	// Initiates a request for cross-origin resource sharing (asks server for Access-Control-* response fields).
	var Origin = "Origin";
	// Implementation-specific fields that may have various effects anywhere along the request-response chain.
	var Pragma = "Pragma";
	// Allows client to request that certain behaviors be employed by a server while processing a request.
	var Prefer = "Prefer";
	// Authorization credentials for connecting to a proxy.
	var ProxyAuthorization = "Proxy-Authorization";
	// Request only part of an entity.  Bytes are numbered from 0.  See Byte serving.
	var Range = " Range";
	// This is the address of the previous web page from which a link to the currently requested page was followed. (The word "referrer" has been misspelled in the RFC as well as in most implementations to the point that it has become standard usage and is considered correct terminology)
	var Referer = "Referer";
	// The transfer encodings the user agent is willing to accept: the same values as for the response header field Transfer-Encoding can be used, plus the "trailers" value (related to the "chunked" transfer method) to notify the server it expects to receive additional fields in the trailer after the last, zero-sized, chunk. Only trailers is supported in HTTP/2.
	var TE = "TE";
	// The Trailer general field value indicates that the given set of header fields is present in the trailer of a message encoded with chunked transfer coding.
	var Trailer = "Trailer";
	// The form of encoding used to safely transfer the entity to the user. Currently defined methods are: chunked, compress, deflate, gzip, identity. Must not be used with HTTP/2.
	var TransferEncoding = "Transfer-Encoding";
	// The user agent string of the user agent.
	var UserAgent = "User-Agent";
	// Ask the server to upgrade to another protocol. Must not be used in HTTP/2.
	var Upgrade = "Upgrade";
	// Informs the server of proxies through which the request was sent.
	var Via = "Via";
	// A general warning about possible problems with the entity body.
	var Warning = "Warning";
}