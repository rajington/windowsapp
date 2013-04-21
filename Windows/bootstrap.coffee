api =
  settings: ->
    SDAPI.settings()

  allWindows: ->
    __jsc__.toJS SDWindowProxy.allWindows()

  visibleWindows: ->
    __jsc__.toJS SDWindowProxy.visibleWindows()

  focusedWindow: ->
    SDWindowProxy.focusedWindow()

  mainScreen: ->
    SDScreenProxy.mainScreen()

  allScreens: ->
    __jsc__.toJS SDScreenProxy.allScreens()

  selectedText: ->
    SDWindowProxy.selectedText()

  clipboardContents: ->
    body = NSPasteboard.generalPasteboard().stringForType(NSPasteboardTypeString)
    if body
      body.toString()
    else
      null

shell = (path, args, input, pwd) ->
  SDAPI.shell_args_input_pwd_ path, args, input, pwd

open = (thing) ->
  SDAPI.shell_args_input "/usr/bin/open", [thing], null

bind = (key, modifiers, fn) ->
  SDKeyBinder.sharedKeyBinder().bind_modifiers_fn_ key, modifiers, fn

alert = (str) ->
  if arguments.length is 2
    SDAlertWindowController.sharedAlertWindowController().show_delay_ str, arguments[1]
  else
    SDAlertWindowController.sharedAlertWindowController().show_ str

log = (str) ->
  SDLogWindowController.sharedLogWindowController().show_type_ str, "SDLogMessageTypeUser"

expandPath = (path) ->
  NSString.stringWithString_(path).stringByStandardizingPath()

readFile = (file) ->
  path = expandPath(file)
  NSString.stringWithContentsOfFile_encoding_error_ path, NSUTF8StringEncoding, null

require = ((globalContext) ->
  (file) ->
    file = NSString.stringWithString_(file)
    contents = readFile(file)
    return false  unless contents
    if file.hasSuffix(".js")
      eval.call globalContext, String(contents)
    else eval.call globalContext, coffeeToJS(contents)  if file.hasSuffix(".coffee")
    true
)(this)

_reloadConfig = ->
  file = SDConfigLoader.configFileToUse()
  unless file
    alert "Can't find either ~/.windowsapp.{coffee,js}\n\nMake one exist and try Reload Config again.", 7
    return
  SDKeyBinder.sharedKeyBinder().removeKeyBindings()
  return  unless require(file)
  failures = SDKeyBinder.sharedKeyBinder().finalizeNewKeyBindings()
  if failures.count > 0
    log "The following hot keys could not be bound:\n\n" + failures.componentsJoinedByString("\n")
  else
    alert ((if typeof @__loadedBefore is "undefined" then "Loaded " else "Reloaded ")) + file
    @__loadedBefore = true

reloadConfig = ->

  # without doAsync, reloading your configs from an interactive
  # action initiated by a function in your config breaks everything.
  SDAPI.doAsync ->
    _reloadConfig()
