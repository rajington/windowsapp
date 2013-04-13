//
//  BindkeyOp.m
//  Windows
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDKeyBinder.h"

#import "MASShortcut+Monitoring.h"
#import "SDKeyBindingTranslator.h"

#import <JSCocoa/JSCocoa.h>



@interface SDJSBlockWrapper : NSObject
@property JSContextRef mainContext;
@property JSValueRef actualFn;
@end

@implementation SDJSBlockWrapper

- (id) initWithJavaScriptFn:(JSValueRefAndContextRef)fn {
    if (self = [super init]) {
        self.mainContext = [[JSCocoa controllerFromContext:fn.ctx] ctx];
        self.actualFn = fn.value;
        
        JSValueProtect(self.mainContext, self.actualFn);
    }
    return self;
}

- (void) call {
    [[JSCocoa controllerFromContext:self.mainContext] callJSFunction:(JSObjectRef)(self.actualFn)
                                                       withArguments:nil];
}

- (void) dealloc {
    JSValueUnprotect(self.mainContext, self.actualFn);
}

@end



@interface SDHotKey : NSObject
@property NSArray* modifiers;
@property NSString* key;
@property SDJSBlockWrapper* fn;
@end

@implementation SDHotKey

- (id) bindAndReturnHandler {
    NSUInteger code = [SDKeyBindingTranslator keyCodeForString:self.key];
    NSUInteger mods = [SDKeyBindingTranslator modifierFlagsForStrings:self.modifiers];
    
    MASShortcut *defaultShortcut = [MASShortcut shortcutWithKeyCode:code modifierFlags:mods];
    
    return [MASShortcut addGlobalHotkeyMonitorWithShortcut:defaultShortcut handler:^{
        [self.fn call];
    }];
}

@end



@interface SDKeyBinder ()

@property NSArray* upcomingHotKeys;
@property NSArray* globalHandlers;

@end

@implementation SDKeyBinder

- (void) bind:(NSString*)key modifiers:(NSArray*)mods fn:(JSValueRefAndContextRef)fn {
    SDHotKey* hotkey = [[SDHotKey alloc] init];
    hotkey.key = key;
    hotkey.modifiers = mods;
    hotkey.fn = [[SDJSBlockWrapper alloc] initWithJavaScriptFn:fn];
    
    self.upcomingHotKeys = [[NSArray arrayWithArray:self.upcomingHotKeys] arrayByAddingObject:hotkey];
}

- (void) removeKeyBindings {
    for (id oldHandler in self.globalHandlers) {
        [MASShortcut removeGlobalHotkeyMonitor:oldHandler];
    }
}

- (void) finalizeNewKeyBindings {
    NSMutableArray* handlers = [NSMutableArray array];
    
    for (SDHotKey* hotkey in self.upcomingHotKeys) {
        [handlers addObject:[hotkey bindAndReturnHandler]];
    }
    
    self.globalHandlers = handlers;
    self.upcomingHotKeys = nil;
}

@end