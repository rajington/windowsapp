//
//  AppDelegate.m
//  Windows
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "AppDelegate.h"

#import <JSCocoa/JSCocoa.h>

#import "SDKeyBinder.h"
#import "SDConfigProblemReporter.h"
#import "SDWindowProxy.h"

@interface AppDelegate ()

@property JSCocoa* jsc;
@property SDKeyBinder* bindkeyOp;
@property NSStatusItem* statusItem;

@property SDConfigProblemReporter* problemReporter;

@end

@implementation AppDelegate

- (void) prepareStatusItem {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.image = [NSImage imageNamed:@"statusitem"];
    self.statusItem.alternateImage = [NSImage imageNamed:@"statusitem_pressed"];
    self.statusItem.menu = self.statusItemMenu;
    self.statusItem.highlightMode = YES;
}

- (void) JSCocoa:(JSCocoaController*)controller hadError:(NSString*)error onLineNumber:(NSInteger)lineNumber atSourceURL:(id)url {
    [self reportProblem:[NSString stringWithFormat:@"Error in config file on line: %ld\n\n%@", lineNumber, error]];
}

- (void) prepareScriptingBridge {
    self.jsc = [JSCocoa new];
    self.jsc.delegate = self;
    self.bindkeyOp = [[SDKeyBinder alloc] init];
    
    [self.jsc setObject:self withName:@"App"];
    [self.jsc setObject:[SDWindowProxy self] withName:@"Win"];
    [self.jsc setObject:self.bindkeyOp withName:@"Keys"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self prepareStatusItem];
    [self prepareScriptingBridge];
    [self reloadConfig];
}

- (void) reportProblem:(NSString*)problem {
    if (self.problemReporter == nil)
        self.problemReporter = [[SDConfigProblemReporter alloc] init];
    
    self.problemReporter.problem = problem;
    
    [NSApp activateIgnoringOtherApps:YES];
    
    [[self.problemReporter window] center];
    [self.problemReporter showWindow:nil];
}

- (void) reloadConfig {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"relaoding config...");
        
        NSString* path = [@"~/.windowsapp" stringByStandardizingPath];
        NSString* config = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        
        if (config == nil) {
            [self reportProblem:@"~/.windowsapp doesn't exist"];
            return;
        }
        
        NSString* __autoreleasing invalidReason;
        BOOL validSyntax = [self.jsc isSyntaxValid:config error:&invalidReason];
        
        if (validSyntax == NO) {
            [self reportProblem:invalidReason];
            return;
        }
        
        [self.bindkeyOp removeKeyBindings];
        
        [self.jsc evalJSString:config];
        
        [self.bindkeyOp finalizeNewKeyBindings];
    });
}

- (IBAction) reloadConfig:(id)sender {
    [self reloadConfig];
}

@end
