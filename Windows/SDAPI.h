//
//  SDAPI.h
//  Windows
//
//  Created by Steven on 4/15/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <JSCocoa/JSCocoa.h>

#import "SDWindowProxy.h"
#import "SDScreenProxy.h"

@interface SDAPISettings : NSObject

@property CGFloat alertDisappearDelay;
@property BOOL alertAnimates;
- (NSBox*) alertBox;
- (NSTextField*) alertTextField;

@end

@interface SDAPI : NSObject

+ (void) bind:(NSString*)key modifiers:(NSArray*)mods fn:(JSValueRefAndContextRef)fn;

+ (void) doAsync:(JSValueRefAndContextRef)fn;

+ (void) reloadConfig;
+ (void) alert:(NSString*)str;
+ (void) alert:(NSString*)str withDelay:(CGFloat)delay;
+ (void) print:(NSString*)str;

+ (SDAPISettings*) settings;

+ (NSArray*) allWindows;
+ (NSArray*) visibleWindows;
+ (SDWindowProxy*) focusedWindow;

+ (SDScreenProxy*) mainScreen;
+ (NSArray*) allScreens;

@end
