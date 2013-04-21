class Screen
  constructor: (@proxy) ->
  frameIncludingDockAndMenu: -> @proxy.frameIncludingDockAndMenu()
  frameWithoutDockOrMenu: -> @proxy.frameWithoutDockOrMenu()
  nextScreen: -> @proxy.nextScreen()
  previousScreen: -> @proxy.previousScreen()

class App
  constructor: (@proxy) ->
  isHidden: -> @proxy.isHidden()
  windows: -> @proxy.windows()
  title: -> @proxy.title()
  kill: -> @proxy.kill()
  kill9: -> @proxy.kill9()

class Window
  constructor: (@proxy) ->
  topLeft: -> @proxy.topLeft()
  size: -> @proxy.size()
  frame: -> @proxy.frame()
  setTopLeft: (x) -> @proxy.setTopLeft(x)
  setSize: (x) -> @proxy.setSize(x)
  setFrame: (x) -> @proxy.setFrame(x)
  maximize: -> @proxy.maximize()
  app: -> new App @proxy.app()
  screen: -> new Screen @proxy.screen()
  otherWindowsOnSameScreen: -> _.map __jsc__.toJS(@proxy.otherWindowsOnSameScreen()), (screen) -> new Screen screen
  title: -> @proxy.title()
  isWindowMinimized: -> @proxy.isWindowMinimized()
  focusWindow: -> @proxy.focusWindow()
  focusWindowLeft: -> @proxy.focusWindowLeft()
  focusWindowRight: -> @proxy.focusWindowRight()
  focusWindowUp: -> @proxy.focusWindowUp()
  focusWindowDown: -> @proxy.focusWindowDown()

api =
  settings: -> SDAPI.settings()
  runningApps: -> _.map __jsc__.toJS(SDAppProxy.runningApps()), (app) -> new App app
  allWindows: -> _.map __jsc__.toJS(SDWindowProxy.allWindows()), (win) -> new Window win
  visibleWindows: -> _.map __jsc__.toJS(SDWindowProxy.visibleWindows()), (win) -> new Window win
  focusedWindow: -> new Window SDWindowProxy.focusedWindow()
  mainScreen: -> SDScreenProxy.mainScreen()
  allScreens: -> __jsc__.toJS SDScreenProxy.allScreens()
  selectedText: -> __jsc__.toJS SDWindowProxy.selectedText()
  clipboardContents: ->
    body = NSPasteboard.generalPasteboard().stringForType(NSPasteboardTypeString)
    if body
      body.toString()
    else
      null

shell = (path, args, input, pwd) -> SDAPI.shell_args_input_pwd_ path, args, input, pwd
open = (thing) -> SDAPI.shell_args_input "/usr/bin/open", [thing], null
bind = (key, modifiers, fn) -> SDKeyBinder.sharedKeyBinder().bind_modifiers_fn_ key, modifiers, fn
listen = (event, fn) -> SDEventListener.sharedEventListener().listenForEvent_fn_(event, fn)
log = (str) -> SDLogWindowController.sharedLogWindowController().show_type_ str, "SDLogMessageTypeUser"
require = (file) -> SDConfigLoader.sharedConfigLoader().require(file)
alert = (str, delay) -> SDAlertWindowController.sharedAlertWindowController().show_delay_ str, delay
reloadConfig = -> SDConfigLoader.sharedConfigLoader().reloadConfig()
