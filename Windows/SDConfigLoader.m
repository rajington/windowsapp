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
#import "SDAlertWindowController.h"
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
    self.jscocoa.useAutoCall = YES;
    self.jscocoa.useSplitCall = NO;
    self.jscocoa.delegate = self;
    self.jscocoa.useJSLint = NO;
    [self.jscocoa evalJSFile:[[NSBundle mainBundle] pathForResource:@"underscore-min" ofType:@"js"]];
    [self.jscocoa evalJSFile:[[NSBundle mainBundle] pathForResource:@"coffee-script" ofType:@"js"]];
    self.jscocoa.useJSLint = YES;
    
    [self.jscocoa setObject:[SDAPI self] withName:@"api"];
    
    NSString* exportsJSPath = [[NSBundle mainBundle] pathForResource:@"exports" ofType:@"js"];
    [self.jscocoa evalJSFile:exportsJSPath];
}

- (void) reloadConfig {
    JSValueRef compileFn = [self.jscocoa evalJSString:@"reloadConfig"];
    
    [self.jscocoa callJSFunction:(JSObjectRef)compileFn
                   withArguments:nil];
}

- (void) JSCocoa:(JSCocoaController*)controller hadError:(NSString*)error onLineNumber:(NSInteger)lineNumber atSourceURL:(id)url {
    NSString* msg = [NSString stringWithFormat:
                     @"=== Problem ===\n"
                     @"Error in config file on line: %ld\n\n%@",
                     lineNumber, error];
    [[SDMessageWindowController sharedMessageWindowController] show:msg];
}

@end
