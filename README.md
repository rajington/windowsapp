# Windows.app

*The OS X window manager for hackers*

* **Install:** `brew install --HEAD https://raw.github.com/sdegutis/windowsapp/master/windows-app.rb`
* Current version: **2.0.3**
* Requires: OS X 10.7 and up
* Note: Building from homebrew requires Xcode to be installed

Table of contents:

* [No really, what is Windows.app?](#no-really-what-is-windowsapp)
* [Usage](#usage)
* [Example Config](#example-config)
* [More Configs](#more-configs)
* [API](#api)
* [License](#license)
* [Change log](#change-log)
* [Todo](#todo)

## No really, what is Windows.app?

At it's core, Windows.app is just a program that runs quietly in your menu bar, and evaluates your config file `~/.windowsapp.{coffee,js}` whenever you tell it to. The config file can be either CoffeeScript 1.6.2 or JavaScript, depending on the extension you use.

In this config file, you can access Windows.app's [simple API](#api), which gives you a few powers:

- bind global hot keys to your own functions
- find the focused window
- determine window sizes and positions
- move and resize windows
- change focus to another window
- move focus to the closest window in a given direction
- and more!

## Usage

Run the app. Then create your config file at `~/.windowsapp.{coffee,js}` and put some code in it. Then reload the config file from the menu. (You may want to bind a hot key to reload the app during testing for convenience.)

You can use either `~/.windowsapp.coffee` or `~/.windowsapp.js`. If both exist, only the CoffeeScript one is used.

Your config file has access to [underscore.js 1.4.4](http://underscorejs.org/).

Note: if your config file fails to load for some reason, all your key bindings are un-bound (as a precaution, presuming that your config file is in an unpredictable state). They will be re-bound again next time your config file is successfully loaded.

## Example Config

Put the following in `~/.windowsapp.coffee`

```coffeescript
# reload this config for testing
bind "R", ["cmd", "alt", "ctrl"], ->
  api.reloadConfig

# maximize window
bind "M", ["cmd", "alt", "ctrl"], ->
  win = api.focusedWindow
  frame = win.screen.frameWithoutDockOrMenu
  win.setFrame frame

# push to top half of screen
bind "K", ["cmd", "alt", "ctrl"], ->
  win = api.focusedWindow
  frame = win.screen.frameWithoutDockOrMenu
  frame.size.height /= 2
  win.setFrame frame

# push to bottom half of screen
bind "J", ["cmd", "alt", "ctrl"], ->
  win = api.focusedWindow
  frame = win.screen.frameWithoutDockOrMenu
  frame.origin.y += frame.size.height / 2
  frame.size.height /= 2
  win.setFrame frame
```

## More Configs

The [wiki home page](https://github.com/sdegutis/windowsapp/wiki) has a list of configs from users, and configs that replicate other apps (like SizeUp and Divvy).

## API

### Top Level

```coffeescript
- (API) api;

- (void) alert(String str)                 # shows in a fancy alert
- (void) print(String str[, Float delay])  # shows in a plain old text box; optional delay is seconds

- (void) bind(String key,              # case-insensitive single-character string; see link below
              Array<String> modifiers, # may contain any number of: "cmd", "ctrl", "alt", "shift"
              Function fn)             # javascript fn that takes no args; return val is ignored
- (void) require(String path) # may be JS or CS file; looks at extension to know which
```

The function `bind()` uses [this list](https://github.com/sdegutis/windowsapp/blob/master/Windows/SDKeyBindingTranslator.m#L148) of key strings.

### Type: `API`

```coffeescript
- (void) reloadConfig

- (Settings) settings

- (Array<Window>) allWindows
- (Array<Window>) visibleWindows
- (Window) focusedWindow

- (Screen) mainScreen
- (Array<Screen>) allScreens
```

### Type: `Settings`

```coffeescript
property (Float) alertDisappearDelay # in seconds
property (Boolean) alertAnimates # when opening

- (NSBox) alertBox
- (NSTextField) alertTextField
```

### Type: `Window`

```coffeescript
- (CGRect) frame
- (void) setFrame(CGRect frame)

- (CGPoint) topLeft
- (void) setTopLeft(CGPoint thePoint)

- (CGSize) size
- (void) setSize(CGSize theSize)

- (void) maximize


- (Screen) screen
- (Array<Window>) otherWindowsOnSameScreen


- (String) title
- (Boolean) isWindowMinimized
- (Boolean) isAppHidden


- (Boolean) focusWindow

- (void) focusWindowLeft
- (void) focusWindowRight
- (void) focusWindowUp
- (void) focusWindowDown
```

### Type: `Screen`

```coffeescript
- (CGRect) frameIncludingDockAndMenu
- (CGRect) frameWithoutDockOrMenu

- (Screen) nextScreen
- (Screen) previousScreen
```

### Other Types

The rest of the types here are classes from ObjC, bridged to JS. Here's a few for reference:

```coffeescript
type CGRect

property (CGPoint) origin # top-left point on screen
property (CGSize) size


type CGSize

property (Float) width
property (Float) height


type CGPoint

property (Float) x
property (Float) y
```

The rest you'll have to look up for yourself.

## License

MIT (see [LICENSE](Licenses/LICENSE) file)

## Change log

- HEAD
  - Fixed some alert() visual uglies
  - When keys can't be bound, show them in a more readable way
  - Tweaked 'About' window
  - Added some more `alert` options to API
- 2.0.3
  - Renamed `popupDisappearDelay` to `alertDisappearDelay`
- 2.0.2
  - Bound the rest of the keys
- 2.0.1
  - Gave alert an optional 'delay' parameter
- 2.0
  - Added CoffeeScript option
  - Reorganized and re-awesome'd API
  - Modifier keys don't need to be all caps anymore
- 1.2.3:
  - Added `PopupSettings` to API
- 1.2.2:
  - The dotfile should now be named `~/.windowsapp.js`
  - Added `alert()` and `print()` functions
  - Removed `popup:` and `show:` methods
- 1.2.1:
  - Merged `Msg` class into `App` class in API
  - Added `popup:` method to `App` in API
  - Reloading config now pops something up to tell you about
  - Error window no longer steals focus
- 1.2:
  - Added 'Open at Login' menu item
  - Added `Screen` class to API
  - Added `Msg` class to API
  - Removed `moveToNextScreen` and `moveToPreviousScreen` methods from API
- 1.1.1:
  - Performance improvements and bug fixes
- 1.1:
  - Adds status bar icon
  - Adds app icon
  - Pops up window with explanation if anything goes wrong
- 1.0:
  - Initial stable version (or so I think)

## Todo

* Bug Kyle to make some nice JS helper functions for NSColor maybe?
* Make your top-level variables keep existing after config-reloads maybe?
* Figure out how to automatically distribute pre-compiled binaries
* Figure out how to get it working on 10.6 (weak references aren't allowed there)
* Make it semi-safe to pass wrong stuff into API functions, especially `bind()`
