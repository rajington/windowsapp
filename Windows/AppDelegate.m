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
#import "SDOpenAtLogin.h"

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
    self.bindkeyOp = [[SDKeyBinder alloc] init];
    
    self.jsc = [JSCocoa new];
    self.jsc.delegate = self;
    self.jsc.useJSLint = NO;
    [self.jsc evalJSFile:[[NSBundle mainBundle] pathForResource:@"underscore-min" ofType:@"js"]];
    self.jsc.useJSLint = YES;
    
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
        NSLog(@"reloading config...");
        
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
        
        NSArray* failures = [self.bindkeyOp finalizeNewKeyBindings];
        
        if ([failures count] > 0) {
            NSString* keyDescriptions = [failures componentsJoinedByString:@"\n"];
            NSString* crap = [NSString stringWithFormat:@"The following hot keys could not be bound:\n\n%@", keyDescriptions];
            [self reportProblem:crap];
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
