# Windows.app

*The OS X window manager for hackers*

* Current version: **1.1**
* Requires: OS X 10.7 and up

[Download Windows.app](https://github.com/sdegutis/Windows/raw/master/Windows-1.1.zip)

* [Usage](#Usage)
    * [Why JSCocoa?](#Why-JSCocoa?)
* [Basic Config](Basic Config)
* [Useful Config Tricks](Useful Config Tricks)
    * [Make Cmd-Shift-R reload your config during testing](Make Cmd-Shift-R reload your config during testing)
* [API](API)
* [License](License)
* [Change log](Change log)
* [Todo](Todo)

## Usage

Create your config file at `~/.windowsapp` and write some [JSCocoa](https://github.com/parmanoir/jscocoa/). Then run the app.

### Why JSCocoa?

* Gives you the full power of Javascript, as it's a superset of Javascript
* Gives you nearly the full power of ObjC, including native bracket and dot syntax
* Has complete access to the ObjC runtime including all Foundation and Cocoa classes
    * This means you can do almost anything that ObjC/Cocoa could do
* Doesn't require creating a whole `WebView` just to evaluate JS

## Basic Config

This basic config makes Mash-HJKL move to the "sides" of the screen.

```javascript
// making a convenient function for our purposes
binder = function(letter, fn) {
  [Keys bind:letter modifiers:["CMD", "ALT", "CTRL"] fn: function() {
      var win = [Win focusedWindow];
      var frame = [[win screen] frameInWindowCoordinates]; // start off with the screen's full frame
      fn(win, frame);
  }];
};

binder('M', function(win, frame) {
    [win setFrame: frame]; // we're maximizing, so just set the frame without adjusting it
});

binder('H', function(win, frame) {
    frame.size.width /= 2;
    [win setFrame: frame];
});

binder('L', function(win, frame) {
    frame.origin.x += frame.size.width / 2;
    frame.size.width /= 2;
    [win setFrame: frame];
});

binder('K', function(win, frame) {
    frame.size.height /= 2;
    [win setFrame: frame];
});

binder('J', function(win, frame) {
    frame.origin.y += frame.size.height / 2;
    frame.size.height /= 2;
    [win setFrame: frame];
});

// Cmd-Shift-R reloads this config for testing
[Keys bind:"R" modifiers:["SHIFT", "CMD"] fn: function() {
    [App reloadConfig];
}];
```

## Useful Config Tricks

### Make Cmd-Shift-R reload your config during testing

```javascript
[Keys bind:"R" modifiers:["SHIFT", "CMD"] fn: function() {
    [App reloadConfig];
}];
```

### Use variables for common modifiers

```javascript
var mash = ["CMD", "ALT", "CTRL"];
[Keys bind:"H" modifiers:mash fn:function() { [[Win focusedWindow] focusWindowLeft]; }];
[Keys bind:"L" modifiers:mash fn:function() { [[Win focusedWindow] focusWindowRight]; }];
[Keys bind:"J" modifiers:mash fn:function() { [[Win focusedWindow] focusWindowDown]; }];
[Keys bind:"K" modifiers:mash fn:function() { [[Win focusedWindow] focusWindowUp]; }];
```

### Show an alert pop-up

```javascript
var showAlert = function(title, text) {
    [NSApp activateIgnoringOtherApps:true];
    var win = NSAlert.alloc.init;
    win.messageText = title;
    win.informativeText = text;
    [win runModal];
};

[Keys bind:"z" modifiers:["CMD"] fn: function() {
    showAlert("stop using undo!", "the past is the past.\n\njust accept it and move on.");
}];
```

### Create a window

This creates a window with the same frame as the focused window, makes it green, and brings it to the foreground

```javascript
var showWindow = function() {
    var frame = Win.focusedWindow.frame;

    [NSApp activateIgnoringOtherApps:true];

    var w  = [[NSWindow alloc] initWithContentRect:frame
                                     styleMask:NSTitledWindowMask | NSClosableWindowMask
                                       backing:NSBackingStoreBuffered
                                         defer:NO];
    [w setBackgroundColor:[NSColor greenColor]];

    [w makeKeyAndOrderFront:null];
};

[Keys bind:"p" modifiers:["CMD"] fn: function() {
    showWindow();
}];
```

## API

```objc
@class App

- (void) reloadConfig;
```

```objc
@class Keys

- (void) bind:(NSString*)key
    modifiers:(NSArray*)mods
           fn:(JSValueRefAndContextRef)fn;

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

- (void) setTopLeft:(CGPoint)thePoint;
- (void) setSize:(CGSize)theSize;

- (CGPoint) topLeft;
- (CGSize) size;

- (void) maximize;


// screens

- (NSScreen*) screen;

- (void) moveToNextScreen;
- (void) moveToPreviousScreen;


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
@class NSScreen

- (CGRect) frameInWindowCoordinates; // all the good names were taken
```

## License

MIT (see [LICENSE](LICENSE) file)

## Change log

- 1.1:
  - Adds status bar icon
  - Adds app icon
  - Pops up window with explanation if anything goes wrong
- 1.0:
  - Initial stable version (or so I think)

## Todo

* Allow the rest of the keys in BindkeyLegacyTranslator.m
* Make it semi-safe to pass wrong stuff into API functions, especially `-bind:...`
