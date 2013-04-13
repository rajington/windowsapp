# Windows.app

*The OS X window manager for hackers*

## Advantages over alternatives

* Doesn't have tons of memory leaks
* Easy to navigate/tweak source code
* Uses [JSCocoa](https://github.com/parmanoir/jscocoa/) to get full power of ObjC while still being JavaScript
* Extremely light-weight

## Usage

Create a file `~/.windowsapp` and add some JSCocoa configs to it.

## Fun Configs

### Make Cmd-Shift-R reload your config during testing

```javascript
[Keys bind:"R" modifiers:["SHIFT", "CMD"] fn: function() {
    [App reloadConfig];
}];
```

### Make Cmd-Shift-H and Cmd-Shift-L move window to left and right halves of screen

```javascript
[Keys bind:"H" modifiers:["SHIFT", "CMD"] fn: function() {
    var win = [Windows focusedWindow];
    var newFrame = [[win screen] correctFrameForSerious];
    newFrame.size.width /= 2;
    [win setFrame: newFrame];
}];

[Keys bind:"H" modifiers:["SHIFT", "CMD"] fn: function() {
    var win = [Windows focusedWindow];
    var newFrame = [[win screen] correctFrameForSerious];
    newFrame.origin.x += newFrame.size.width / 2;
    newFrame.size.width /= 2;
    [win setFrame: newFrame];
}];
```

### Use variables for common modifiers

```javascript
var mash = ["CMD", "ALT", "CTRL"];
[Keys bind:"H" modifiers:mash fn:function() { [[Windows focusedWindow] focusWindowLeft]; }];
[Keys bind:"L" modifiers:mash fn:function() { [[Windows focusedWindow] focusWindowRight]; }];
[Keys bind:"J" modifiers:mash fn:function() { [[Windows focusedWindow] focusWindowDown]; }];
[Keys bind:"K" modifiers:mash fn:function() { [[Windows focusedWindow] focusWindowUp]; }];
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
@class Windows

// getting windows

+ (NSArray*) allWindows;
+ (NSArray*) visibleWindows;
+ (SDWindowProxy*) focusedWindow;
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

- (CGRect) correctFrameForSerious; // all the good names were taken
```
