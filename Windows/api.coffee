mapToJS = (list, fn) -> _.map __jsc__.toJS(list), fn
objToJS = (obj) -> __jsc__.toJS obj

class Screen
  @fromNS: (proxy) -> new Screen proxy
  constructor: (@proxy) ->
  frameIncludingDockAndMenu: -> @proxy.frameIncludingDockAndMenu()
  frameWithoutDockOrMenu: -> @proxy.frameWithoutDockOrMenu()
  nextScreen: -> Screen.fromNS @proxy.nextScreen()
  previousScreen: -> Screen.fromNS @proxy.previousScreen()

class App
  @fromNS: (proxy) -> new App proxy
  constructor: (@proxy) ->
  isHidden: -> @proxy.isHidden()
  allWindows: -> mapToJS @proxy.allWindows(), Window.fromNS
  visibleWindows: -> mapToJS @proxy.visibleWindows(), Window.fromNS
  title: -> @proxy.title()
  kill: -> @proxy.kill()
  kill9: -> @proxy.kill9()

class Window
  @fromNS: (proxy) -> new Window proxy
  constructor: (@proxy) ->
  topLeft: -> @proxy.topLeft()
  size: -> @proxy.size()
  frame: -> @proxy.frame()
  setTopLeft: (x) -> @proxy.setTopLeft(x)
  setSize: (x) -> @proxy.setSize(x)
  setFrame: (x) -> @proxy.setFrame(x)
  maximize: -> @proxy.maximize()
  app: -> App.fromNS @proxy.app()
  isNormalWindow: -> @proxy.isNormalWindow()
  screen: -> Screen.fromNS @proxy.screen()
  otherWindowsOnSameScreen: -> mapToJS @proxy.otherWindowsOnSameScreen(), Screen.fromNS
  title: -> @proxy.title()
  isWindowMinimized: -> @proxy.isWindowMinimized()
  focusWindow: -> @proxy.focusWindow()
  focusWindowLeft: -> @proxy.focusWindowLeft()
  focusWindowRight: -> @proxy.focusWindowRight()
  focusWindowUp: -> @proxy.focusWindowUp()
  focusWindowDown: -> @proxy.focusWindowDown()

api =
  settings: -> SDAPI.settings()
  runningApps: -> mapToJS SDAppProxy.runningApps(), App.fromNS
  allWindows: -> mapToJS SDWindowProxy.allWindows(), Window.fromNS
  visibleWindows: -> mapToJS SDWindowProxy.visibleWindows(), Window.fromNS
  focusedWindow: -> Window.fromNS SDWindowProxy.focusedWindow()
  mainScreen: -> SDScreenProxy.mainScreen()
  allScreens: -> mapToJS SDScreenProxy.allScreens(), Screen.fromNS
  selectedText: -> objToJS SDWindowProxy.selectedText()
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
doAfter = (sec, fn) -> SDAPI.doFn_after_ fn, sec

listen = (event, fn) ->
  trampolineFn = (thing) ->
    switch thing.className().toString()
      when 'SDWindowProxy'
        fn Window.fromNS(thing)
      when 'SDAppProxy'
        fn App.fromNS(thing)
  SDEventListener.sharedEventListener().listenForEvent_fn_(event, trampolineFn)
