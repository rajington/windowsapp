//
//  AppDelegate.m
//  Windows
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "AppDelegate.h"

#import <JSCocoa/JSCocoa.h>

#import "SDBindkeyOp.h"

#import "SDWindowProxy.h"

@interface AppDelegate ()

@property JSCocoa* jsc;

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

- (void) prepareScriptingBridge {
    self.jsc = [JSCocoa new];
    
    self.bindkeyOp = [[SDBindkeyOp alloc] init];
    
    [self.jsc setObject:self withName:@"App"];
    [self.jsc setObject:[SDWindowProxy self] withName:@"Windows"];
    [self.jsc setObject:self.bindkeyOp withName:@"Keys"];
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
    
    [self.jsc evalJSFile:[@"~/.windowsapp" stringByStandardizingPath]];
    
    [self.bindkeyOp finalizeNewKeyBindings];
}

@end
