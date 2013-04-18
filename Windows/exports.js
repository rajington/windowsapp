// important! JSCocoa doesn't do ARC. so if we do alloc, we need to do autorelease, old school

var bind = function(key, modifiers, fn) {
  api.bind_modifiers_fn_(key, modifiers, fn);
};

var alert = function(str) {
  if (arguments.length == 2)
    api.alert_withDelay(str, arguments[1]);
  else
    api.alert(str);
};
var print = function(str) { api.print(str); };

var expandPath = function(path) {
  return NSString.stringWithString(path).stringByStandardizingPath;
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
    file = NSString.stringWithString(file)

    var contents = readFile(file);

    if (!contents)
      return false;

    if (file.hasSuffix('.js'))
      eval.call(globalContext, String(contents));
    else if (file.hasSuffix('.coffee'))
      eval.call(globalContext, compile(contents));

    return true;
  };
})(this);

var reloadConfigExt = function(file) {
  SDKeyBinder.sharedKeyBinder.removeKeyBindings;

  if (!require(file))
    return false;

  var failures = SDKeyBinder.sharedKeyBinder.finalizeNewKeyBindings;

  if (failures.count > 0) {
    print("The following hot keys could not be bound:\n\n" + failures.componentsJoinedByString("\n"));
  }
  else {
    alert((typeof this.__loadedBefore == 'undefined' ? "Loaded config " : "Reloaded config ") + file);
    this.__loadedBefore = true;
  }

  return true;
};

var reloadConfig = function() {
  api.doAsync(function() {
    if (!reloadConfigExt('~/.windowsapp.coffee') && !reloadConfigExt('~/.windowsapp.js')) {
      alert("Can't find either ~/.windowsapp.{coffee,js}\n\nMake one exist and try Reload Config again.", 7);
    }
  });
}
