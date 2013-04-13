//
//  AppDelegate.m
//  Windows
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "AppDelegate.h"

#import <Nu/Nu.h>

#import "SDTrampolineOp.h"
#import "SDBindkeyOp.h"

#import "SDWindowProxy.h"

@interface AppDelegate ()

@property SDBindkeyOp* bindkeyOp;

@property NSStatusItem* statusItem;

@end

@implementation AppDelegate

- (void) prepareStatusItem {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.title = @"Windows!";
    self.statusItem.menu = self.statusItemMenu;
    self.statusItem.highlightMode = YES;
}

- (void) addFunctionNamed:(NSString*)fnName block:(id(^)(id cdr, NSMutableDictionary* ctx))blk {
    NuParser* parser = [Nu sharedParser];
    
    SDTrampolineOp* trampOp = [[SDTrampolineOp alloc] init];
    trampOp.fn = blk;
    [[parser context] setObject:trampOp forKey:[fnName symbolValue]];
}

- (void) prepareScriptingBridge {
    NuParser* parser = [Nu sharedParser];
    
    __weak AppDelegate* weakSelf = self; // just to get rid of the warning
    
    [self addFunctionNamed:@"reload-config" block:^id(id cdr, NSMutableDictionary *ctx) {
        [weakSelf reloadConfig:nil];
        return nil;
    }];
    
    [self addFunctionNamed:@"all-windows" block:^id(id cdr, NSMutableDictionary *ctx) {
        return [SDWindowProxy allWindows];
    }];
    
    [self addFunctionNamed:@"visible-windows" block:^id(id cdr, NSMutableDictionary *ctx) {
        return [SDWindowProxy visibleWindows];
    }];
    
    [self addFunctionNamed:@"focused-window" block:^id(id cdr, NSMutableDictionary *ctx) {
        return [SDWindowProxy focusedWindow];
    }];
    
    self.bindkeyOp = [[SDBindkeyOp alloc] init];
    [[parser context] setObject:self.bindkeyOp forKey:[@"bindkey" symbolValue]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self prepareStatusItem];
    [self prepareScriptingBridge];
    [self readUserConfigFile];
}

- (IBAction) reloadConfig:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self readUserConfigFile];
    });
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
