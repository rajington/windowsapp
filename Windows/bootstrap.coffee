api =
  settings: -> SDAPI.settings()
  allWindows: -> __jsc__.toJS SDWindowProxy.allWindows()
  visibleWindows: -> __jsc__.toJS SDWindowProxy.visibleWindows()
  focusedWindow: -> SDWindowProxy.focusedWindow()
  mainScreen: -> SDScreenProxy.mainScreen()
  allScreens: -> __jsc__.toJS SDScreenProxy.allScreens()
  selectedText: -> SDWindowProxy.selectedText()
  clipboardContents: ->
    body = NSPasteboard.generalPasteboard().stringForType(NSPasteboardTypeString)
    if body
      body.toString()
    else
      null

shell = (path, args, input, pwd) -> SDAPI.shell_args_input_pwd_ path, args, input, pwd
open = (thing) -> SDAPI.shell_args_input "/usr/bin/open", [thing], null
bind = (key, modifiers, fn) -> SDKeyBinder.sharedKeyBinder().bind_modifiers_fn_ key, modifiers, fn
log = (str) -> SDLogWindowController.sharedLogWindowController().show_type_ str, "SDLogMessageTypeUser"
require = (file) -> SDConfigLoader.sharedConfigLoader().require(file)
alert = (str, delay) -> SDAlertWindowController.sharedAlertWindowController().show_delay_ str, delay
reloadConfig = -> SDConfigLoader.sharedConfigLoader().reloadConfig()
