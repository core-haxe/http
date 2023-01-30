package http.impl.nodejs;

class FormData extends FormDataBase {
    private var _formData:FormDataExtern = new FormDataExtern();

    public override function append(name:String, value:Any) {
        _formData.append(name, value);
    }

    public override function build():String {
        return _formData.getBuffer().toString();
    }

    public override function buildHeaders():Map<String, String> {
        var map:Map<String, String> = [];
        var headers = _formData.getHeaders();
        for (f in Reflect.fields(headers)) {
            var v = Reflect.field(headers, f);
            map.set(f, v);
        }
        return map;
    }
}

@:jsRequire("form-data")
private extern class FormDataExtern {
    public function new();
    public function append(name:String, value:Any):Void;
    public function getBuffer():Dynamic;
    public function getHeaders():Dynamic;
}