# Windows.app

*The OS X window manager for hackers*

* Current version: **2.1.2**
* Requires: OS X 10.7 and up
* Download: [latest .zip file](https://raw.github.com/sdegutis/windowsapp/master/Builds/Windows-LATEST.app.tar.gz), unzip, right-click app, choose "Open"

Table of contents:

* [Overview](#overview)
* [Example Config](#example-config)
* [More Configs](#more-configs)
* [API](#api)
* [Change log](#change-log)
* [Todo](#todo)
* [License](#license)

## Overview

At it's core, Windows.app is just a program that runs quietly in your menu bar, and loads a config file in your home directory.

You can either write your config file in [CoffeeScript](http://coffeescript.org/) (1.6.2) as `~/.windowsapp.coffee`, or JavaScript as `~/.windowsapp.js`. For your convenience, [underscore.js](http://underscorejs.org/) (1.4.4) is loaded beforehand.

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

Feel free to put some `.coffee` or `.js` files in `~/.windowsapp/` and `require()` them from your main config file. This directory is watched by the auto-reload feature.

#### Auto-Reload Configs

When you enable this feature via the menu, Windows.app will reload your config file any time `~/.windowsapp.coffee`, `~/.windowsapp.js`, or any file within `~/.windowsapp/` changes.

#### Config Caveats

If both config files exist, the most recently modified one will be chosen. You can override this by using `touch`.

If reloading your config file fails, your key bindings will be un-bound as a precaution, presuming that your config file is in an unpredictable state. They will be re-bound again next time your config file is successfully loaded.

## Example Config

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

- (void) print(String str                  # shows up in the log window
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

- (String) selectedText()
- (String) clipboardContents()
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

- HEAD
  - Renamed `print()` to `log()`
  - Converted all public-facing API to pure JS objects
  - Moved `selectedText()` to `api` object
- 2.1.2
  - All function calls now require parentheses, even if they take no args
- 2.1.1
  - Fix `shell` when giving stdin so it doesn't hang
- 2.1
  - Config files now eval in the same `this` every time
  - The "config loaded" alert show which config has been used
  - Adds `shell`, `open`, `clipboardContents`, `selectedText` functions
  - Determines which config file to use based on which was edited more recently
  - Added option to auto-reload your config file when it changes
- 2.0.4
  - Added an automatic updater!
  - Fixed some alert() visual uglies
  - When keys can't be bound, show them in a more readable way
  - Tweaked 'About' window
  - Added some more `alert` options to API
  - Message window appends strings if it's already open
  - Added `require()` function
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

* UI
    * New Log window plan:
        * It uses a WebView for easier styling than NSTextView
        * At the bottom of the window is a text field that acts as a REPL
        * Different types of messages display differently
            * Errors = red, user-messages = blue, REPL results = green
        * After printing a new message, it auto-scrolls to the bottom
        * Before each message, it shows the timestamp of when it was sent
        * Between each message, it inserts a &lt;hr&gt;
        * Don't clear the window each time it opens, leave it full
        * Add a button to let you clear it when/if you want to
        * There's still one problem:
            * What happens when the error that opened the log goes away?
                * We still have to manually close the log, that's annoying.
                * How do we solve this?
                  * Maybe become a hybrid of what it is now and the alert window?
* API
    * Add `api.evalSelectedText()` for live/interactive REPL action
        * Make note if it in the README, reminding people they can just highlight someone else's config and run `evalSelectedText` to try it out for themselves
        * Also remind them that they can just run `reloadConfig` to undo the other person's key-bindings
    * Better error handling when passing wrong stuff into API functions
    * Figure out a way to not have to do nil-checks so often
    * Add events to API (`kAXWindowCreatedNotification`, etc)
    * Add `App` type for NSRunningApplication, extract it out of `Window` (it's already there)
    * Make some nice JS helper functions for NSColor
    * Maybe bring back Nu again?
        * It's a fine language, it's just not as easy to manipulate CGRects with it as with JS/CS
    * Figure out if we can use ClojureScript
        * Would we even want to? It's not that conductive to OOP
* Other
    * Figure out how to get it working on 10.6 (weak references aren't allowed there)

## License

It's been said that a project's license reveals what the authors were afraid of. For example, if they're afraid of having their name dragged through the mud, they'll choose the BSD over MIT, and if they're afraid people will use their work in some proprietary project without contributing back to the community, they'll choose the GPL over either. Therefore, this software is licensed under the [MIT license](Licenses/LICENSE) with the additional clause that by using this software you agree not to put spiders or any other bugs under my pillow or blankets.
