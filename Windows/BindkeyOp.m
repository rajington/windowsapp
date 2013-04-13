//
//  BindkeyOp.m
//  Windows
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "BindkeyOp.h"

#import <Nu/Nu.h>
#import "MASShortcut+Monitoring.h"
#import "BindkeyLegacyTranslator.h"

@interface BindkeyPair : NSObject
@property NSArray* modifiers;
@property NSString* key;
@property NuBlock* fn;
@property NSMutableDictionary* ctx;
@end

@implementation BindkeyPair
@end


@interface BindkeyOp ()

@property NSArray* upcomingHotKeys;
@property NSArray* globalHandlers;

@end

@implementation BindkeyOp

- (id) callWithArguments:(NuCell*) cdr context:(NSMutableDictionary *) context {
    BindkeyPair* pair = [[BindkeyPair alloc] init];
    pair.modifiers = [[[cdr car] evalWithContext:context] array];
    pair.key = [[[cdr cdr] car] evalWithContext:context];
    pair.fn = [[[[cdr cdr] cdr] car] evalWithContext:context];
    pair.ctx = context;
    
    self.upcomingHotKeys = [[NSArray arrayWithArray:self.upcomingHotKeys] arrayByAddingObject:pair];
    
    return nil;
}

- (void) removeKeyBindings {
    for (id oldHandler in self.globalHandlers) {
        [MASShortcut removeGlobalHotkeyMonitor:oldHandler];
    }
}

- (void) finalizeNewKeyBindings {
    NSMutableArray* handlers = [NSMutableArray array];
    
    for (BindkeyPair* bindkeyPair in self.upcomingHotKeys) {
        MASShortcut *defaultShortcut = [MASShortcut shortcutWithKeyCode:[BindkeyLegacyTranslator keyCodeForString:bindkeyPair.key]
                                                          modifierFlags:[BindkeyLegacyTranslator modifierFlagsForStrings:bindkeyPair.modifiers]];
        
        id handler = [MASShortcut addGlobalHotkeyMonitorWithShortcut:defaultShortcut handler:^{
            [bindkeyPair.fn evalWithArguments:nil
                                      context:bindkeyPair.ctx];
        }];
        
        [handlers addObject:handler];
    }
    
    self.globalHandlers = handlers;
    self.upcomingHotKeys = nil;
}

@end
