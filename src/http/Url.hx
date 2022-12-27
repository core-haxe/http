package http;

@:forward
@:forward.new
abstract Url(UrlObject) {
    @:from public static function fromString(s:String):Url {
        return new Url(s);
    }
}