package cases;

import utest.Assert;
import http.Url;

class TestUrl extends TestBase {
    function testBasic() {
        var url = new Url("https://httpbin.org");
        Assert.equals("https", url.scheme);
        Assert.equals("httpbin.org", url.domain);
        Assert.equals("", url.path);
        Assert.same(new Map<String, Any>(), url.queryParams);
        Assert.equals("https://httpbin.org", url.build());
    }

    function testPath() {
        var url = new Url("https://httpbin.org/foo/bar");
        Assert.equals("https", url.scheme);
        Assert.equals("httpbin.org", url.domain);
        Assert.equals("/foo/bar", url.path);
        Assert.same(new Map<String, Any>(), url.queryParams);
        Assert.equals("https://httpbin.org/foo/bar", url.build());
    }

    function testQueryParams() {
        var url = new Url("https://httpbin.org?param1=value1&param2=value2");
        Assert.equals("https", url.scheme);
        Assert.equals("httpbin.org", url.domain);
        Assert.equals("", url.path);
        Assert.same(["param1" => "value1", "param2" => "value2"], url.queryParams);
        Assert.equals("https://httpbin.org?param1=value1&param2=value2", url.build());
    }

    function testQueryParams_NoBuild() {
        var url = new Url("https://httpbin.org?param1=value1&param2=value2");
        Assert.equals("https", url.scheme);
        Assert.equals("httpbin.org", url.domain);
        Assert.equals("", url.path);
        Assert.same(["param1" => "value1", "param2" => "value2"], url.queryParams);
        Assert.equals("https://httpbin.org", url.build(false));
    }

    function testPathQueryParams() {
        var url = new Url("https://httpbin.org/foo/bar?param1=value1&param2=value2");
        Assert.equals("https", url.scheme);
        Assert.equals("httpbin.org", url.domain);
        Assert.equals("/foo/bar", url.path);
        Assert.same(["param1" => "value1", "param2" => "value2"], url.queryParams);
        Assert.equals("https://httpbin.org/foo/bar?param1=value1&param2=value2", url.build());
    }

    function testPathQueryParams_NoBuild() {
        var url = new Url("https://httpbin.org/foo/bar?param1=value1&param2=value2");
        Assert.equals("https", url.scheme);
        Assert.equals("httpbin.org", url.domain);
        Assert.equals("/foo/bar", url.path);
        Assert.same(["param1" => "value1", "param2" => "value2"], url.queryParams);
        Assert.equals("https://httpbin.org/foo/bar", url.build(false));
    }
}