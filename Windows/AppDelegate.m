//
//  AppDelegate.m
//  Windows
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "AppDelegate.h"

#import <Nu/Nu.h>

#import "MASShortcut+Monitoring.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    MASShortcut *defaultShortcut = [MASShortcut shortcutWithKeyCode:0x2 modifierFlags:NSCommandKeyMask|NSShiftKeyMask];
    
    [MASShortcut addGlobalHotkeyMonitorWithShortcut:defaultShortcut
                                            handler:^{
                                                NSLog(@"hi!");
                                            }];
    
//    NuParser* parser = [Nu sharedParser];
//    [[parser context] setObject:@8 forKey:[@"a" symbolValue]];
//    id code = [parser parse:@"(+ a 2)"];
//    id result = [parser eval:code];
//    NSLog(@"%@", result);
}

@end
