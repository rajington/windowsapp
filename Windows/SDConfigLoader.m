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
#import "SDLogWindowController.h"

@interface SDConfigLoader ()

@property JSCocoa* jscocoa;

@end


void fsEventsCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[])
{
    [[SDConfigLoader sharedConfigLoader] reloadConfigIfWatchEnabled];
}

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
    self.jscocoa.useAutoCall = NO;
    
    [self.jscocoa evalJSFile:[[NSBundle mainBundle] pathForResource:@"underscore-min" ofType:@"js"]];
    [self.jscocoa evalJSFile:[[NSBundle mainBundle] pathForResource:@"coffee-script" ofType:@"js"]];
    [self.jscocoa evalJSFile:[[NSBundle mainBundle] pathForResource:@"exports" ofType:@"js"]];
    
    [self watchDirs];
}

- (void) reloadConfigIfWatchEnabled {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AutoReloadConfigs"]) {
        // this guards against there sometimes being 2 notifications in a row
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadConfig) object:nil];
        [self performSelector:@selector(reloadConfig) withObject:nil afterDelay:0.1];
    }
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
    [[SDLogWindowController sharedLogWindowController] show:msg];
}

- (void) watchDirs {
    NSArray *pathsToWatch = @[[@"~/.windowsapp.js" stringByStandardizingPath],
                              [@"~/.windowsapp.coffee" stringByStandardizingPath],
                              [@"~/.windowsapp" stringByStandardizingPath]];
    FSEventStreamContext context;
    context.info = NULL;
    context.version = 0;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    FSEventStreamRef stream = FSEventStreamCreate(NULL,
                                                  fsEventsCallback,
                                                  &context,
                                                  (__bridge CFArrayRef)pathsToWatch,
                                                  kFSEventStreamEventIdSinceNow,
                                                  0.4,
                                                  kFSEventStreamCreateFlagWatchRoot | kFSEventStreamCreateFlagNoDefer | kFSEventStreamCreateFlagFileEvents);
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
}

+ (NSString*) configFileToUse {
    NSString* coffeeFile = @"~/.windowsapp.coffee";
    NSString* jsFile = @"~/.windowsapp.js";
    
    NSArray* prettyChoices = @[coffeeFile, jsFile];
    NSArray* choices = [prettyChoices valueForKeyPath:@"stringByStandardizingPath"];
    
    NSDictionary* results = [NSDictionary dictionaryWithObjects:prettyChoices forKeys:choices];
    
    NSMutableArray* finalContenders = [NSMutableArray array];
    
    for (NSString* candidate in choices) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:candidate] && [[NSFileManager defaultManager] isReadableFileAtPath:candidate]) {
            NSURL* url = [[NSURL fileURLWithPath:candidate] URLByResolvingSymlinksInPath];
            NSDictionary* attrs = [url resourceValuesForKeys:@[NSURLContentModificationDateKey] error:NULL];
            [finalContenders addObject:@{@"file": candidate, @"timestamp": [attrs objectForKey:NSURLContentModificationDateKey]}];
        }
    }
    
    if ([finalContenders count] == 2) {
        [finalContenders sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
            NSDate* date1 = [obj1 objectForKey:@"timestamp"];
            NSDate* date2 = [obj2 objectForKey:@"timestamp"];
            return [date1 compare: date2];
        }];
    }
    
    return [results objectForKey:[[finalContenders lastObject] objectForKey:@"file"]];
}

@end
