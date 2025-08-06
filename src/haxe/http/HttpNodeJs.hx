/*
 * Copyright (C)2005-2019 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

 package haxe.http;

 import haxe.macro.Type.Ref;
#if nodejs
 import haxe.io.Bytes;
 import js.node.Buffer;
 import js.node.url.URL;
 class HttpNodeJs extends haxe.http.HttpBase {
     var req:js.node.http.ClientRequest;
 
     public var responseHeaders:Map<String, Any>;

     public function new(url:String) {
         super(url);
     }
 
     /**
         Cancels `this` Http request if `request` has been called and a response
         has not yet been received.
     **/
     public function cancel() {
         if (req == null)
             return;
         req.abort();
         req = null;
     }
 
     public override function request(?post:Bool) {
         responseAsString = null;
         responseBytes = null;
         responseHeaders = null;
         var parsedUrl = new URL(url);
         var secure = (parsedUrl.protocol == "https:");
         var host = parsedUrl.hostname;
         var path = parsedUrl.pathname;
         var queryParams = parsedUrl.search;
         if (queryParams != null && queryParams.length > 0) {
            if (!StringTools.startsWith(queryParams, "?")) {
                queryParams = "?" + queryParams;
            }
        } 
        if (queryParams != null) {
            path += queryParams;
        }
         var port = if (parsedUrl.port != null) Std.parseInt(parsedUrl.port) else (secure ? 443 : 80);
         var h:Dynamic = {};
         /* ORIGINAL CODE ALWAYS SENT HEADERS AS AN ARRAY - this broke if "Host" was used
         for (i in headers) {
             var arr = Reflect.field(h, i.name);
             if (arr == null) {
                 arr = new Array<String>();
                 Reflect.setField(h, i.name, arr);
             }
 
             arr.push(i.value);
         }
         */
        // this sets the header to the value (which could be an array if needed)  
        for (i in headers) {
            Reflect.setField(h, i.name, i.value);
        }

         if (postData != null || postBytes != null)
             post = true;
         var uri = null;
         for (p in params) {
             if (uri == null)
                 uri = "";
             else
                 uri += "&";
          
         				var k = p.name;
         				var v = p.value;
         				if (encodeUrl) {
         					k = StringTools.urlEncode(p.name);
         					v = StringTools.urlEncode(p.value);
         				}
         				uri += k + "=" + v;
         }
      
         var question = path.split("?").length <= 1;
         if (uri != null)
             path += (if (question) "?" else "&") + uri;
 
         var method = post ? 'POST' : 'GET';
         if (_customRequestMethod != null) {
            method = _customRequestMethod;
         }
         if (_customRequestPost != null) {
            post = _customRequestPost;
         }

         var opts = {
             protocol: parsedUrl.protocol,
             hostname: host,
             port: port,
             method: method,
             path: path,
             headers: h
         };
         function httpResponse(res) {
             res.setEncoding('binary');
             var s = res.statusCode;
             if (s != null)
                 onStatus(s);
             var data = [];
             res.on('data', function(chunk:String) {
                 data.push(Buffer.from(chunk, 'binary'));
             });
             res.on('end', function(_) {
                if (res.headers != null) {
                    responseHeaders = new Map<String, Any>();
                    for (f in Reflect.fields(res.headers)) {
                        var v = Reflect.field(res.headers, f);
                        responseHeaders.set(f, v);
                    }
                }
                 var buf = (data.length == 1 ? data[0] : Buffer.concat(data));
                 responseBytes = Bytes.ofData(buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength));
                 req = null;
                 if (s != null && s >= 200 && s < 400) {
                     success(responseBytes);
                 } else {
                     onError("Http Error #" + s);
                 }
             });
         }
         req = secure ? js.node.Https.request(untyped opts, httpResponse) : js.node.Http.request(untyped opts, httpResponse);
         if (post)
             if (postData != null) {
                 req.write(postData);
             } else if(postBytes != null) {
                 req.setHeader("Content-Length", '${postBytes.length}');
                 req.write(Buffer.from(postBytes.getData()));
             }
 
         req.end();
         req.on('error', function(e) {
            onError("No connection");
         });
     }
 
     private var _customRequestMethod:String = null;
     private var _customRequestPost:Null<Bool> = null;
     public function customRequest(post:Bool, ?method:String):Void {
         _customRequestPost = post;
         _customRequestMethod = method;
     }
 }
 #end
 
