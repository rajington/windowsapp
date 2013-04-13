//
//  AppDelegate.m
//  Windows
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "AppDelegate.h"

#import <Nu/Nu.h>

#import "BindkeyOp.h"

@interface AppDelegate ()

@property BindkeyOp* bindkeyOp;

@property NSStatusItem* statusItem;

@end

@implementation AppDelegate

- (void) prepareStatusItem {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.title = @"Windows!";
    self.statusItem.menu = self.statusItemMenu;
    self.statusItem.highlightMode = YES;
}

- (void) prepareScriptingBridge {
    NuParser* parser = [Nu sharedParser];
    
    self.bindkeyOp = [[BindkeyOp alloc] init];
    [[parser context] setObject:self.bindkeyOp
                         forKey:[@"bindkey" symbolValue]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self prepareStatusItem];
    [self prepareScriptingBridge];
    [self readUserConfigFile];
}

- (IBAction) reloadConfig:(id)sender {
    [self readUserConfigFile];
}

- (void) readUserConfigFile {
    NSString* path = [@"~/.windowsapp" stringByStandardizingPath];
    NSString* config = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    if (config == nil) {
        NSLog(@"~/.windowsapp doesn't exist");
        return;
    }
    
    [self.bindkeyOp removeKeyBindings];
    
    NuParser* parser = [Nu sharedParser];
    [parser eval:[parser parse:config]];
    
    [self.bindkeyOp finalizeNewKeyBindings];
}

@end
