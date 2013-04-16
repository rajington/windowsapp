var bind = function(key, modifiers, fn) {
    api.bind_modifiers_fn_(key, modifiers, fn);
};

var expandPath = function(path) {
    return [[NSString stringWithString:path] stringByStandardizingPath];
};

var readFile = function(file) {
    var path = expandPath(file);
    return NSString.stringWithContentsOfFile_encoding_error(path, NSUTF8StringEncoding, null);
};

var compile = function(coffee) {
    return CoffeeScript.compile(coffee, { bare: true });
};

var require = (function(globalContext) {
    return function(file) {
        var path = expandPath(file);
        var contents = readFile(path);

        if (path.hasSuffix('.js'))
            eval.call(globalContext, contents)
        else if (path.hasSuffix('.coffee'))
            eval.call(globalContext, compile(contents));
    };
})(this);
