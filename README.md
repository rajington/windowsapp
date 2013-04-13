# Windows.app

*The OS X window manager for hackers*

Current version: **1.0**

## Advantages over alternatives

* Doesn't have tons of memory leaks
* Easy to navigate/tweak source code
* Uses [JSCocoa](https://github.com/parmanoir/jscocoa/) to get full power of ObjC while still being JavaScript
* Extremely light-weight

## Usage

Create a file `~/.windowsapp` and add some JSCocoa configs to it. Then run the app.

## Basic Config

This config makes Mash-HJKL move to the "sides" of the screen.

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

// key: a single-character string
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

[Public Domain, CC0 style](http://en.wikipedia.org/wiki/Creative_Commons_license#Public_domain)

## Changelog:

- 1.0:
  - Initial stable version (or so I think)

## Todo:

* Allow the rest of the keys in BindkeyLegacyTranslator.m
* Make it semi-safe to pass wrong stuff into API functions, especially `-bind:...`
* Make it not crash the whole app just because the config file has a tiny bug somewhere
