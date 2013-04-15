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
#import "SDPopupWindowController.h"
#import "SDMessageWindowController.h"
#import "SDWindowProxy.h"
#import "SDScreenProxy.h"
#import "SDOpenAtLogin.h"

@interface AppDelegate ()

@property JSCocoa* jscocoa;
@property SDKeyBinder* keyBinder;
@property NSStatusItem* statusItem;

@property SDPopupWindowController* popupWindowController;
@property SDMessageWindowController* messageWindowController;

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
    [self reportProblem:[NSString stringWithFormat:@"Error in config file on line: %ld", lineNumber]
                   body:error];
}

- (void) prepareScriptingBridge {
    self.keyBinder = [[SDKeyBinder alloc] init];
    
    self.jscocoa = [JSCocoa new];
    self.jscocoa.delegate = self;
    self.jscocoa.useJSLint = NO;
    [self.jscocoa evalJSFile:[[NSBundle mainBundle] pathForResource:@"underscore-min" ofType:@"js"]];
    self.jscocoa.useJSLint = YES;
    
    [self.jscocoa setObject:self withName:@"App"];
    [self.jscocoa setObject:[SDWindowProxy self] withName:@"Win"];
    [self.jscocoa setObject:[SDScreenProxy self] withName:@"Screen"];
    [self.jscocoa setObject:self.keyBinder withName:@"Keys"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.messageWindowController = [[SDMessageWindowController alloc] init];
    self.popupWindowController = [[SDPopupWindowController alloc] init];
    
    [self prepareStatusItem];
    [self prepareScriptingBridge];
    [self reloadConfig];
}

- (void) show:(NSString*)msg {
    [self.messageWindowController show:msg];
}

- (void) popup:(NSString*)msg {
    [self.popupWindowController show:msg];
}

- (void) reportProblem:(NSString*)problem body:(NSString*)body {
    NSString* msg = [NSString stringWithFormat:@"=== Problem ===\n%@\n\n%@", problem, body];
    [self.messageWindowController show:msg];
}

- (void) reloadConfig {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"reloading config...");
        
        NSString* path = [@"~/.windowsapp.js" stringByStandardizingPath];
        NSString* config = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        
        if (config == nil) {
            [self reportProblem:@"~/.windowsapp.js doesn't exist"
                           body:@"Make it exist and try again maybe?"];
            return;
        }
        
        NSString* __autoreleasing invalidReason;
        BOOL validSyntax = [self.jscocoa isSyntaxValid:config error:&invalidReason];
        
        if (validSyntax == NO) {
            [self reportProblem:@"Your config file has bad syntax."
                           body:invalidReason];
            return;
        }
        
        [self.keyBinder removeKeyBindings];
        
        [self.jscocoa evalJSString:config];
        
        NSArray* failures = [self.keyBinder finalizeNewKeyBindings];
        
        if ([failures count] > 0) {
            [self reportProblem:@"The following hot keys could not be bound:"
                           body:[failures componentsJoinedByString:@"\n"]];
        }
        else {
            [self.popupWindowController show:@"Config reloaded."];
        }
    });
}

- (IBAction) reloadConfig:(id)sender {
    [self reloadConfig];
}

- (void) menuNeedsUpdate:(NSMenu *)menu {
    [[menu itemWithTitle:@"Open at Login"] setState:([SDOpenAtLogin opensAtLogin] ? NSOnState : NSOffState)];
}

- (IBAction) toggleOpensAtLogin:(id)sender {
	NSInteger changingToState = ![sender state];
	[SDOpenAtLogin setOpensAtLogin: changingToState];
}

@end
