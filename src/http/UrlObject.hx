package http;

import haxe.io.Path;
using StringTools;

class UrlObject {
    public var scheme:String;
    public var domain:String;
    public var path:String;

    public function new(url:String = null) {
        if (url != null) {
            parse(url);
        }
    }

    private var _queryParams:Map<String, Any>;
    public var queryParams(get, set):Map<String, Any>;
    private function get_queryParams():Map<String, Any> {
        if (_queryParams == null) {
            _queryParams = [];
        }
        return _queryParams;
    }
    private function set_queryParams(value:Map<String, Any>):Map<String, Any> {
        _queryParams = value;
        return value;
    }

    public function build(includeParams:Bool = true):String {
        var sb = new StringBuf();
        
        if (scheme != null) {
            sb.add(scheme);
        } else {
            sb.add("http");
        }

        sb.add("://");

        var temp = "";
        if (domain != null) {
            temp += domain.trim();
        }
        if (path != null) {
            temp += path.trim();
        }
        temp = Path.normalize(temp);
        sb.add(temp);

        if (includeParams && _queryParams != null) {
            var parts = [];
            for (key in _queryParams.keys()) {
                parts.push(key + "=" + _queryParams.get(key));
            }

            if (parts.length > 0) {
                sb.add("?");
                sb.add(parts.join("&"));
            }
        }

        return sb.toString();
    }

    public function parse(url:String) {
        scheme = null;
        domain = null;
        path = null;
        _queryParams = null;

        url = url.trim();
        var n1 = url.indexOf("://");
        if (n1 != -1) {
            scheme = url.substring(0, n1);
            url = url.substr(n1 + "://".length);
        }

        var n2 = url.indexOf("/");
        if (n2 == -1) {
            n2 = url.indexOf("?");
        }
        if (n2 == -1) {
            n2 = url.length;
        }
        if (n2 != -1) {
            domain = url.substring(0, n2);
            url = url.substr(n2);
        }

        if (!url.startsWith("?")) {
            var n3 = url.lastIndexOf("?");
            if (n3 == -1) {
                n3 = url.indexOf("/");
            }
            if (n3 == -1) {
                n3 = url.length;
            }
            if (n3 != -1) {
                path = url.substring(0, n3);
                url = url.substring(n3);
            }
        }

        var n4 = url.indexOf("?");
        if (n4 != -1) {
            var queryParams = url.substr(n4 + 1);
            var paramParts = queryParams.split("&");
            for (paramPart in paramParts) {
                if (_queryParams == null) {
                    _queryParams = [];
                }
                var parts = paramPart.split("=");
                _queryParams.set(parts[0].trim(), parts[1].trim());
            }
            url = "";
        }

        if (url.length != 0) {
            path = url;
        }

        if (path == null) {
            path = "";
        }
    }
}