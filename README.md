# Windows.app

*The OS X window manager for hackers*

* **Install:** `brew install --HEAD https://raw.github.com/sdegutis/windows/master/windows.rb`
* Current version: **1.2.3**
* Requires: OS X 10.7 and up


Table of contents:

* [No really, what is Windows.app?](#no-really-what-is-windowsapp)
* [Usage](#usage)
* [Basic Config](#basic-config)
* [Really Cool Config](#really-cool-config)
* [Other People's Configs](#other-peoples-configs)
* [API](#api)
* [License](#license)
* [Change log](#change-log)
* [Todo](#todo)

## No really, what is Windows.app?

The original goal was to create a bare-bones, minimalist window manager for OS X. But it turns out to be more than that.

At it's core, Windows.app is just a program that runs quietly in your menu bar, and evaluates the config file `~/.windowsapp.js` (written in [JSCocoa](https://github.com/parmanoir/jscocoa/)) whenever you tell it to.

In this config file, you can access Windows.app's [simple API](#api), which lets you bind global hot keys to your own functions, determine window sizes and positions, move and resize windows, move focus to the closest window in a given direction, and more.

But technically, you can do anything you want in this file. Because it's JSCocoa, it has complete access to all of the Cocoa and Foundation frameworks and ObjC runtime.

## Usage

Run the app. Then create your config file at `~/.windowsapp.js` and write some [JSCocoa](https://github.com/parmanoir/jscocoa/). Then reload the config file from the menu. (You may want to bind a hot key to reload the app (see the [basic config example](#basic-config)) during testing so you don't have to click the menu bar icon to do it.)

The config file has access to [underscore.js](http://underscorejs.org/).

### About JSCocoa

JSCocoa is basically a subset of JavaScript with some ObjC-like syntactic sugar. Check out [the official syntax page](https://code.google.com/p/jscocoa/).

* Gives you the full power of Javascript, as it's a superset of Javascript
* Gives you nearly the full power of ObjC, including native bracket and dot syntax
* Has complete access to the ObjC runtime including all Foundation and Cocoa classes
    * This means you can do almost anything that ObjC/Cocoa could do

## Basic Config

```javascript
// maximize window
[Keys bind:'M' modifiers:['CMD', 'ALT', 'CTRL'] fn: function() {
    var win = Win.focusedWindow;
    var frame = win.screen.frameWithoutDockOrMenu;
    win.frame = frame;
}];

// push to top half of screen
[Keys bind:'K' modifiers:['CMD', 'ALT', 'CTRL'] fn: function() {
    var win = [Win focusedWindow];
    var frame = win.screen.frameWithoutDockOrMenu;
    frame.size.height /= 2;
    win.frame = frame;
}];

// push to bottom half of screen
[Keys bind:'J' modifiers:['CMD', 'ALT', 'CTRL'] fn: function() {
    var win = [Win focusedWindow];
    var frame = win.screen.frameWithoutDockOrMenu;
    frame.origin.y += frame.size.height / 2;
    frame.size.height /= 2;
    win.frame = frame;
}];

// reload this config for testing
[Keys bind:'R' modifiers:['CMD', 'ALT', 'CTRL'] fn: function() {
    [App reloadConfig];
}];
```

## Really Cool Config

This makes your screen act like a grid, and lets you move and resize windows within it:

```javascript
var mash = ["CMD", "ALT", "CTRL"];

// reload this config for testing
[Keys bind:"R" modifiers:mash fn: function() {
    [App reloadConfig];
}];

// snap this window to grid
[Keys bind:"." modifiers:mash fn: function() {
    var win = [Win focusedWindow];
    var r = gridProps(win);
    moveToGridProps(win, r);
}];

// snap all windows to grid
[Keys bind:"," modifiers:mash fn: function() {
    _.each([Win visibleWindows], function(win) {
        var r = gridProps(win);
        moveToGridProps(win, r);
    });
}];

// move left
[Keys bind:"H" modifiers:mash fn: function() {
    var win = [Win focusedWindow];
    var r = gridProps(win);
    r.origin.x = Math.max(r.origin.x - 1, 0);
    moveToGridProps(win, r);
}];

// move right
[Keys bind:"L" modifiers:mash fn: function() {
    var win = [Win focusedWindow];
    var r = gridProps(win);
    r.origin.x = Math.min(r.origin.x + 1, 3 - r.size.width);
    moveToGridProps(win, r);
}];

// grow to right
[Keys bind:"O" modifiers:mash fn: function() {
    var win = [Win focusedWindow];
    var r = gridProps(win);
    r.size.width = Math.min(r.size.width + 1, 3 - r.origin.x);
    moveToGridProps(win, r);
}];

// shrink from right
[Keys bind:"I" modifiers:mash fn: function() {
    var win = [Win focusedWindow];
    var r = gridProps(win);
    r.size.width = Math.max(r.size.width - 1, 1);
    moveToGridProps(win, r);
}];

// move to upper row
[Keys bind:"K" modifiers:mash fn: function() {
    var win = [Win focusedWindow];
    var r = gridProps(win);
    r.origin.y = 0;
    r.size.height = 1;
    moveToGridProps(win, r);
}];

// move to lower row
[Keys bind:"J" modifiers:mash fn: function() {
    var win = [Win focusedWindow];
    var r = gridProps(win);
    r.origin.y = 1;
    r.size.height = 1;
    moveToGridProps(win, r);
}];

// fill whole vertical column
[Keys bind:"U" modifiers:mash fn: function() {
    var win = [Win focusedWindow];
    var r = gridProps(win);
    r.origin.y = 0;
    r.size.height = 2;
    moveToGridProps(win, r);
}];

// throw to next screen
[Keys bind:"N" modifiers:mash fn: function() {
    var win = [Win focusedWindow];
    moveToGridPropsOnScreen(win, [[win screen] nextScreen], gridProps(win));
}];

// throw to previous screen (come on, who ever has more than 2 screens?)
[Keys bind:"P" modifiers:mash fn: function() {
    var win = [Win focusedWindow];
    moveToGridPropsOnScreen(win, [[win screen] previousScreen], gridProps(win));
}];

// helper functions

var gridProps = function(win) {
    var winFrame = [win frame];
    var screenRect = [[win screen] frameWithoutDockOrMenu];

    var thirdScrenWidth = screenRect.size.width / 3.0;
    var halfScreenHeight = screenRect.size.height / 2.0;

    return CGRectMake(Math.round((winFrame.origin.x - NSMinX(screenRect)) / thirdScrenWidth),
                      Math.round((winFrame.origin.y - NSMinY(screenRect)) / halfScreenHeight),
                      Math.max(Math.round(winFrame.size.width / thirdScrenWidth), 1),
                      Math.max(Math.round(winFrame.size.height / halfScreenHeight), 1));
};

var moveToGridProps = function(win, gridProps) {
  moveToGridPropsOnScreen(win, [win screen], gridProps);
}

var moveToGridPropsOnScreen = function(win, screen, gridProps) {
    var screenRect = [screen frameWithoutDockOrMenu];

    var thirdScrenWidth = screenRect.size.width / 3.0;
    var halfScreenHeight = screenRect.size.height / 2.0;

    var newFrame = CGRectMake((gridProps.origin.x * thirdScrenWidth) + NSMinX(screenRect),
                              (gridProps.origin.y * halfScreenHeight) + NSMinY(screenRect),
                              gridProps.size.width * thirdScrenWidth,
                              gridProps.size.height * halfScreenHeight);

    newFrame = NSInsetRect(newFrame, 5, 5); // acts as a little margin between windows, to give shadows some breathing room
    newFrame = NSIntegralRect(newFrame);

    [win setFrame: newFrame];
};
```

## Other People's Configs

* [Mine](https://github.com/sdegutis/home/blob/master/.windowsapp.js)
* [@pd's](https://github.com/pd/dotfiles/blob/master/windowsapp.js)

Do you have a cool one and want me to add it here? Let me know by [filing an Issue](https://github.com/sdegutis/windows/issues).

## API

```objc
@class App

- (void) reloadConfig;

function alert(str); // shows in a fancy popup
function print(str); // shows in a plain old text box
```

```objc
@class PopupSettings

// use like this:
// foo = PopupSettings.disappearDelay;
// PopupSettings.disappearDelay = 3.0;

@property CGFloat disappearDelay;
```

```objc
@class Keys

- (void) bind:(NSString*)key
    modifiers:(NSArray*)mods
           fn:(JSFunction)fn;

// key: a single-character string (doesn't matter if it's upper-case or lower-case)
// mods: an array of any number of: "CMD", "CTRL", "ALT", "SHIFT", "FN"
// fn: a javascript function that takes no args; return val is ignored
```

```objc
@class Win

// getting windows

+ (NSArray*) allWindows;
+ (NSArray*) visibleWindows;
+ (Win*) focusedWindow;
- (NSArray*) otherWindowsOnSameScreen;


// window position & size

- (CGRect) frame;
- (void) setFrame:(CGRect)frame;

- (CGPoint) topLeft;
- (void) setTopLeft:(CGPoint)thePoint;

- (CGSize) size;
- (void) setSize:(CGSize)theSize;

- (void) maximize;


// screens

- (Screen*) screen;


// focus

- (BOOL) focusWindow;

- (void) focusWindowLeft;
- (void) focusWindowRight;
- (void) focusWindowUp;
- (void) focusWindowDown;


// other window properties

- (NSString *) title;
- (BOOL) isWindowMinimized;
- (BOOL) isAppHidden;
```

```objc
@class Screen

+ (Screen*) mainScreen;
+ (NSArray*) allScreens;

- (CGRect) frameIncludingDockAndMenu;
- (CGRect) frameWithoutDockOrMenu;

- (Screen*) nextScreen;
- (Screen*) previousScreen;

// just in case you need this
- (NSScreen*) actualScreenObject;

```

## License

MIT (see [LICENSE](Licenses/LICENSE) file)

## Change log

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

* Learn how to version properly
* Allow the rest of the keys in BindkeyLegacyTranslator.m
* Make it semi-safe to pass wrong stuff into API functions, especially `-bind:...`
