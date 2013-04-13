//
//  BindkeyOp.m
//  Windows
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDBindkeyOp.h"

#import "MASShortcut+Monitoring.h"
#import "SDBindkeyLegacyTranslator.h"

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
    [[JSCocoa controllerFromContext:self.mainContext] callJSFunction:(JSObjectRef)(self.actualFn) withArguments:nil];
}

- (void) dealloc {
    JSValueUnprotect(self.mainContext, self.actualFn);
}

@end



@interface BindkeyPair : NSObject
@property NSArray* modifiers;
@property NSString* key;
@property SDJSBlockWrapper* fn;
@end

@implementation BindkeyPair
@end


@interface SDBindkeyOp ()

@property NSArray* upcomingHotKeys;
@property NSArray* globalHandlers;

@end

@implementation SDBindkeyOp

- (void) bind:(NSString*)key modifiers:(NSArray*)mods fn:(JSValueRefAndContextRef)fn {
    BindkeyPair* pair = [[BindkeyPair alloc] init];
    pair.key = key;
    pair.modifiers = mods;
    pair.fn = [[SDJSBlockWrapper alloc] initWithJavaScriptFn:fn];
    
    self.upcomingHotKeys = [[NSArray arrayWithArray:self.upcomingHotKeys] arrayByAddingObject:pair];
}

- (void) removeKeyBindings {
    for (id oldHandler in self.globalHandlers) {
        [MASShortcut removeGlobalHotkeyMonitor:oldHandler];
    }
}

- (void) finalizeNewKeyBindings {
    NSMutableArray* handlers = [NSMutableArray array];
    
    for (BindkeyPair* bindkeyPair in self.upcomingHotKeys) {
        MASShortcut *defaultShortcut = [MASShortcut shortcutWithKeyCode:[SDBindkeyLegacyTranslator keyCodeForString:bindkeyPair.key]
                                                          modifierFlags:[SDBindkeyLegacyTranslator modifierFlagsForStrings:bindkeyPair.modifiers]];
        
        id handler = [MASShortcut addGlobalHotkeyMonitorWithShortcut:defaultShortcut handler:^{
            [bindkeyPair.fn call];
        }];
        
        [handlers addObject:handler];
    }
    
    self.globalHandlers = handlers;
    self.upcomingHotKeys = nil;
}

@end
