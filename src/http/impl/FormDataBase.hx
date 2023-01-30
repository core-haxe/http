package http.impl;

class FormDataBase {
    public function new() {
    }

    public function append(name:String, value:Any) {
    }

    public function build():String {
        return "";
    }

    public function buildHeaders():Map<String, String> {
        return [];
    }
}