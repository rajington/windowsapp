# Windows.app

*The OS X window manager for hackers*

* Current version: **2.2.1**
* Requires: OS X 10.7 and up
* Download: [latest .zip file](https://raw.github.com/sdegutis/windowsapp/master/Builds/Windows-LATEST.app.tar.gz), unzip, right-click app, choose "Open"

Table of contents:

* [Overview](#overview)
* [Config Example](#config-example)
* [More Configs](#more-configs)
* [API](#api)
* [Change log](#change-log)
* [Todo](#todo)
* [License](#license)

## Overview

At it's core, Windows.app is just a program that runs quietly in your menu bar, and loads a config file in your home directory.

You can either write your config file in either JavaScript (`~/.windowsapp.js`) or [CoffeeScript 1.6.2](http://coffeescript.org/) (`~/.windowsapp.coffee`). For your convenience, [underscore.js](http://underscorejs.org/) (1.4.4) is loaded beforehand.

Then, in your config file, `bind()` some global hot keys to your own JavaScript functions which do window-managery type things.

Here are some things you can do with Windows.app's [simple API](#api):

- find the focused window
- determine window sizes and positions
- move and resize windows
- change focus to another window
- transfer focus to the closest window in a given direction
- run shell scripts
- open apps, links, or files
- and more!

#### Modular Configs

Feel free to put some `.coffee` or `.js` files in `~/.windowsapp/` and `require()` them from your main config file.

#### Auto-Reload Configs

When you enable this feature via the menu, Windows.app will reload your config file any time `~/.windowsapp.coffee`, `~/.windowsapp.js`, or anything within `~/.windowsapp/` changes.

#### Config Caveats

- If both config files exist, the most recently modified one will be chosen. You can override this by using `touch`.
- If reloading your config file fails, your key bindings will be un-bound as a precaution, presuming that your config file is in an unpredictable state. They will be re-bound again next time your config file is successfully loaded.

## Config Example

Put the following in `~/.windowsapp.coffee`

```coffeescript
# useful for testing
bind "R", ["cmd", "alt", "ctrl"], -> reloadConfig()

# maximize window
bind "M", ["cmd", "alt", "ctrl"], ->
  win = api.focusedWindow()
  win.setFrame win.screen().frameWithoutDockOrMenu()

# push to top half of screen
bind "K", ["cmd", "alt", "ctrl"], ->
  win = api.focusedWindow()
  frame = win.screen().frameWithoutDockOrMenu()
  frame.size.height /= 2
  win.setFrame frame

# push to bottom half of screen
bind "J", ["cmd", "alt", "ctrl"], ->
  win = api.focusedWindow()
  frame = win.screen().frameWithoutDockOrMenu()
  frame.origin.y += frame.size.height / 2
  frame.size.height /= 2
  win.setFrame frame
```

## More Configs

The [wiki home page](https://github.com/sdegutis/windowsapp/wiki) has a list of configs from users, and configs that replicate other apps (like SizeUp and Divvy).

## API

### Top Level

```coffeescript
property (API) api

- (void) log(String str)                   # shows up in the log window
- (void) alert(String str[, Float delay])  # shows in a fancy alert; optional delay is seconds

- (void) bind(String key,              # case-insensitive single-character string; see link below
              Array<String> modifiers, # may contain any number of: "cmd", "ctrl", "alt", "shift"
              Function fn)             # javascript fn that takes no args; return val is ignored

- (void) reloadConfig()
- (void) require(String path) # may be JS or CS file; looks at extension to know which

- (Hash) shell(String path, Array<String> args[, String stdin]) # returns {"stdout": string,
                                                                #          "stderr": string,
                                                                #          "status": int}

- (void) open(String thing) # can be path or URL
```

The function `bind()` uses [this list](https://github.com/sdegutis/windowsapp/blob/master/Windows/SDKeyBindingTranslator.m#L148) of key strings.

### Type: `API`

```coffeescript
- (Settings) settings()

- (Array<Window>) allWindows()
- (Array<Window>) visibleWindows()
- (Window) focusedWindow()

- (Screen) mainScreen()
- (Array<Screen>) allScreens()

- (String) clipboardContents()
- (String) selectedText() # doesn't work in webviews sadly (yet?)
```

### Type: `Settings`

```coffeescript
property (Float) alertDisappearDelay # in seconds.
property (Boolean) alertAnimates     # when opening.

- (NSBox) alertBox()
- (NSTextField) alertTextField()
```

### Type: `Window`

```coffeescript
- (CGPoint) topLeft()
- (CGSize) size()
- (CGRect) frame()

- (void) setTopLeft(CGPoint thePoint)
- (void) setSize(CGSize theSize)
- (void) setFrame(CGRect frame)
- (void) maximize()

- (Screen) screen()
- (Array<Window>) otherWindowsOnSameScreen

- (String) title()
- (Boolean) isWindowMinimized()
- (Boolean) isAppHidden()

- (Boolean) focusWindow()
- (void) focusWindowLeft()
- (void) focusWindowRight()
- (void) focusWindowUp()
- (void) focusWindowDown()
```

### Type: `Screen`

```coffeescript
- (CGRect) frameIncludingDockAndMenu()
- (CGRect) frameWithoutDockOrMenu()

- (Screen) nextScreen()
- (Screen) previousScreen()
```

### Other Types

The rest of the types here are classes from ObjC, bridged to JS. Here's a few for reference:

```coffeescript
# CGRect
property (CGPoint) origin # top-left
property (CGSize) size

# CGSize
property (Float) width
property (Float) height

# CGPoint
property (Float) x
property (Float) y
```

The rest you'll have to look up for yourself.

## Change log

- 2.2.1
  - REPL can now take CoffeeScript or JS
  - Re-styled logs in Log Window
- 2.2
  - Renamed `print()` to `log()`
  - Converted all public-facing API to pure JS objects
  - Moved `selectedText()` to `api` object
  - Revamped Log Window, now includes REPL
- 2.1.2
  - First version anyone should care about

## Todo

* Help wanted! We need:
    * better CSS styling in [the Log Window](Windows/logwindow.html)
    * a better app icon
    * a better menu bar (status item) icon
* UI
    * Make C-n/C-p (and up/down) navigate through history in Log Window/REPL
    * Maybe listen on some port for messages, so you can use emacs as a repl instead
* API
    * Consider wrapping every ObjC type in a pure-JS type, so that there's no unexpected behavior for JS-knowledgeable peoples (currently it's kinda weird)
    * Add `api.evalSelectedText()` for live/interactive REPL action
        * Make note if it in the README, reminding people they can just highlight someone else's config and run `evalSelectedText` to try it out for themselves
        * Also remind them that they can just run `reloadConfig` to undo the other person's key-bindings
    * Better error handling when passing wrong stuff into API functions
    * Figure out a way to not have to do nil-checks so often
    * Add events to API (`kAXWindowCreatedNotification`, etc)
    * Add `App` type for NSRunningApplication, extract it out of `Window` (it's already there)
    * Make some nice JS helper functions for NSColor
    * Add some more languages, especially from [altjs.org](http://altjs.org/) and [this guy's list](https://github.com/jashkenas/coffee-script/wiki/List-of-languages-that-compile-to-JS)
        * Make them user-configurable somehow?
        * Let users "define" a language:
            * `define('.rb', '~/.windowsapp/langs/rubyjs.js', 'RubyJS.compile');` (filename ext, source location, compiler function name)
            * `require('~/.windowsapp/myfile.rb');`
            * Seems legit. Maybe.
* Other
    * Figure out how to get it working on 10.6 (weak references aren't allowed there)

## License

It's been said that a project's license reveals what its authors were afraid of. For example, if they're afraid of having their name dragged through the mud, they'll choose BSD over MIT, and if they're afraid people will use their work in some proprietary project without contributing back to the community, they'll choose GPL over either. Therefore, this software is licensed under the [MIT license](Licenses/LICENSE) with the additional clause that by using this software you agree not to put spiders or any other bugs under my pillow or blanket.
