//
//  SDConfigLoader.m
//  Windows
//
//  Created by Steven on 4/15/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDConfigLoader.h"

#import <JSCocoa/JSCocoa.h>

#import "SDWindowProxy.h"
#import "SDScreenProxy.h"
#import "SDAPI.h"

#import "SDKeyBinder.h"
#import "SDPopupWindowController.h"
#import "SDMessageWindowController.h"

@interface SDConfigLoader ()

@property JSCocoa* jscocoa;

@end

@implementation SDConfigLoader

+ (SDConfigLoader*) sharedConfigLoader {
    static SDConfigLoader* sharedConfigLoader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfigLoader = [[SDConfigLoader alloc] init];
    });
    return sharedConfigLoader;
}

- (void) prepareScriptingBridge {
    self.jscocoa = [JSCocoa new];
    self.jscocoa.useAutoCall = NO;
    self.jscocoa.useSplitCall = NO;
    self.jscocoa.delegate = self;
    self.jscocoa.useJSLint = NO;
    [self.jscocoa evalJSFile:[[NSBundle mainBundle] pathForResource:@"underscore-min" ofType:@"js"]];
    [self.jscocoa evalJSFile:[[NSBundle mainBundle] pathForResource:@"coffee-script" ofType:@"js"]];
    self.jscocoa.useJSLint = YES;
    
    [self.jscocoa setObject:[SDAPI self] withName:@"api"];
    
    [self.jscocoa evalJSString:@"bind = function(key, mods, fn) { api.bind_modifiers_fn_(key, mods, fn); }"];
}

- (void) reloadConfig {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self tryCoffeescriptConfig] && ![self tryJavascriptConfig]) {
            [self reportProblem:@"~/.windowsapp.{coffee,js} doesn't exist"
                           body:@"Make one exist and try again maybe? (If both exist, coffee is chosen.)"];
        }
    });
}

- (BOOL) tryJavascriptConfig {
    NSString* path = [@"~/.windowsapp.js" stringByStandardizingPath];
    NSString* config = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    if (config == nil)
        return NO;
    
    NSString* __autoreleasing invalidReason;
    BOOL validSyntax = [self.jscocoa isSyntaxValid:config error:&invalidReason];
    
    if (validSyntax == NO) {
        [self reportProblem:@"Your config file has bad syntax."
                       body:invalidReason];
        return YES;
    }
    
    [[SDKeyBinder sharedKeyBinder] removeKeyBindings];
    
    [self.jscocoa evalJSString:config];
    
    NSArray* failures = [[SDKeyBinder sharedKeyBinder] finalizeNewKeyBindings];
    
    if ([failures count] > 0) {
        [self reportProblem:@"The following hot keys could not be bound:"
                       body:[failures componentsJoinedByString:@"\n"]];
    }
    else {
        [[SDPopupWindowController sharedPopupWindowController] show:@"Config reloaded."];
    }
    
    return YES;
}

- (BOOL) tryCoffeescriptConfig {
    NSString* path = [@"~/.windowsapp.coffee" stringByStandardizingPath];
    NSString* config = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    if (config == nil)
        return NO;
    
    JSValueRef compileFn = [self.jscocoa evalJSString:@"CoffeeScript.compile"];
    JSValueRef compiledCode = [self.jscocoa callJSFunction:(JSObjectRef)compileFn withArguments:@[config]];
    NSString* compiledCodeStr = [self.jscocoa toObject:compiledCode];
    
    [[SDKeyBinder sharedKeyBinder] removeKeyBindings];
    
    [self.jscocoa evalJSString:compiledCodeStr];
    
    NSArray* failures = [[SDKeyBinder sharedKeyBinder] finalizeNewKeyBindings];
    
    if ([failures count] > 0) {
        [self reportProblem:@"The following hot keys could not be bound:"
                       body:[failures componentsJoinedByString:@"\n"]];
    }
    else {
        [[SDPopupWindowController sharedPopupWindowController] show:@"Config reloaded."];
    }
    
    return YES;
}

- (void) JSCocoa:(JSCocoaController*)controller hadError:(NSString*)error onLineNumber:(NSInteger)lineNumber atSourceURL:(id)url {
    [self reportProblem:[NSString stringWithFormat:@"Error in config file on line: %ld", lineNumber]
                   body:error];
}

- (void) reportProblem:(NSString*)problem body:(NSString*)body {
    NSString* msg = [NSString stringWithFormat:@"=== Problem ===\n%@\n\n%@", problem, body];
    [[SDMessageWindowController sharedMessageWindowController] show:msg];
}

@end
