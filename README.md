# Windows.app

Move/resize your windows with the keyboard; customize it with [JSCocoa](https://github.com/parmanoir/jscocoa/)

## Usage

Create a file `~/.windowsapp` and start off with this basic config:

```objc
[Keys bind:"p"
 modifiers:["SHIFT", "CMD"]
        fn: function() {
    var win = [Windows focusedWindow];
    var newFrame = [win frame];
    newFrame.origin.x += 10;
    [win setFrame: newFrame];
  }];

[Keys bind:"R"
      modifiers:["SHIFT", "CMD"]
        fn: function() {
    [App reloadConfig];
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
