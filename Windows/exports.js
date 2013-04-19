// important! JSCocoa doesn't do ARC. so if we do alloc, we need to do autorelease, old school

var api = {
  settings: function() { return SDAPI.settings(); },
  allWindows: function() { return SDWindowProxy.allWindows(); },
  visibleWindows: function() { return SDWindowProxy.visibleWindows(); },
  focusedWindow: function() { return SDWindowProxy.focusedWindow(); },
  mainScreen: function() { return SDScreenProxy.mainScreen(); },
  allScreens: function() { return SDScreenProxy.allScreens(); },
  selectedText: function() { return SDWindowProxy.selectedText(); },
  clipboardContents: function() {
    var body  = NSPasteboard.generalPasteboard.stringForType(NSPasteboardTypeString)
    if (body)
      return body.toString()
    else
      return null;
  }
};

var shell = function(path, args, input) {
  return SDAPI.shell_args_input(path, args, input);
}

var open = function(thing) {
  SDAPI.shell_args_input("/usr/bin/open", [thing], null);
}

var bind = function(key, modifiers, fn) {
  SDKeyBinder.sharedKeyBinder().bind_modifiers_fn_(key, modifiers, fn);
};

var alert = function(str) {
  if (arguments.length == 2)
    SDAlertWindowController.sharedAlertWindowController().show_delay_(str, arguments[1]);
  else
    SDAlertWindowController.sharedAlertWindowController().show_(str);
};
var log = function(str) { SDLogWindowController.sharedLogWindowController().show_(str); };

var expandPath = function(path) {
  return NSString.stringWithString_(path).stringByStandardizingPath();
};

var readFile = function(file) {
  var path = expandPath(file);
  return NSString.stringWithContentsOfFile_encoding_error_(path, NSUTF8StringEncoding, null);
};

var compileCS = function(coffee) {
  return CoffeeScript.compile(coffee, { bare: true });
};

var require = (function(globalContext) {
  return function(file) {
    file = NSString.stringWithString_(file)

    var contents = readFile(file);

    if (!contents)
      return false;

    if (file.hasSuffix('.js'))
      eval.call(globalContext, String(contents));
    else if (file.hasSuffix('.coffee'))
      eval.call(globalContext, compileCS(contents));

    return true;
  };
})(this);

var _reloadConfig = function(file) {
  SDKeyBinder.sharedKeyBinder().removeKeyBindings();

  if (!require(file))
    return false;

  var failures = SDKeyBinder.sharedKeyBinder().finalizeNewKeyBindings();

  if (failures.count > 0) {
    log("The following hot keys could not be bound:\n\n" + failures.componentsJoinedByString("\n"));
  }
  else {
    alert((typeof this.__loadedBefore == 'undefined' ? "Loaded config " : "Reloaded config ") + file);
    this.__loadedBefore = true;
  }

  return true;
};

var reloadConfig = function() {
  SDAPI.doAsync(function() {
    var configFile = SDConfigLoader.configFileToUse();

    if (configFile)
      _reloadConfig(configFile);
    else
      alert("Can't find either ~/.windowsapp.{coffee,js}\n\nMake one exist and try Reload Config again.", 7);
  });
}
