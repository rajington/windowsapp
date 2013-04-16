//
//  SDAPI.m
//  Windows
//
//  Created by Steven on 4/15/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDAPI.h"

#import "SDWindowProxy.h"
#import "SDScreenProxy.h"

#import "SDConfigLoader.h"
#import "SDKeyBinder.h"

#import "SDAlertWindowController.h"
#import "SDMessageWindowController.h"

@implementation SDAPISettings

- (id) init {
    if (self = [super init]) {
        self.alertDisappearDelay = 1.0;
        self.alertAnimates = YES;
    }
    return self;
}

- (BOOL) alertAnimates {
    return [SDAlertWindowController sharedAlertWindowController].alertAnimates;
}

- (void) setAlertAnimates:(BOOL)alertAnimates {
    [SDAlertWindowController sharedAlertWindowController].alertAnimates = alertAnimates;
}

- (NSBox*) alertBox {
    return [SDAlertWindowController sharedAlertWindowController].box;
}

- (NSTextField*) alertTextField {
    return [SDAlertWindowController sharedAlertWindowController].textField;
}

@end

@implementation SDAPI

+ (SDAPISettings*) settings {
    static SDAPISettings* settings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settings = [[SDAPISettings alloc] init];
    });
    return settings;
}

+ (void) bind:(NSString*)key modifiers:(NSArray*)mods fn:(JSValueRefAndContextRef)fn {
    [[SDKeyBinder sharedKeyBinder] bind:key modifiers:mods fn:fn];
}

+ (void) reloadConfig {
    [[SDConfigLoader sharedConfigLoader] reloadConfig];
}

+ (void) alert:(NSString*)str {
    [[SDAlertWindowController sharedAlertWindowController] show:str];
}

+ (void) alert:(NSString*)str withDelay:(CGFloat)delay {
    [[SDAlertWindowController sharedAlertWindowController] show:str delay:delay];
}

+ (void) print:(NSString*)str {
    [[SDMessageWindowController sharedMessageWindowController] show:str];
}

+ (NSArray*) allWindows {
    return [SDWindowProxy allWindows];
}

+ (NSArray*) visibleWindows {
    return [SDWindowProxy visibleWindows];
}

+ (SDWindowProxy*) focusedWindow {
    return [SDWindowProxy focusedWindow];
}

+ (SDScreenProxy*) mainScreen {
    return [SDScreenProxy mainScreen];
}

+ (NSArray*) allScreens {
    return [SDScreenProxy allScreens];
}

@end
