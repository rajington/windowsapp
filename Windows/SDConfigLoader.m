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

- (void) reloadConfigIfWatchEnabled;

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
    self.jscocoa.delegate = self;
    self.jscocoa.useAutoCall = YES;
    self.jscocoa.useSplitCall = NO;
    self.jscocoa.useJSLint = NO;
    self.jscocoa.useAutoCall = NO;
    
    [self.jscocoa evalJSFile:[[NSBundle mainBundle] pathForResource:@"underscore-min" ofType:@"js"]];
    [self.jscocoa evalJSFile:[[NSBundle mainBundle] pathForResource:@"coffee-script" ofType:@"js"]];
    [self.jscocoa eval:@"function coffeeToJS(coffee) { return CoffeeScript.compile(coffee, { bare: true }); };"];
    [self evalCoffeeFile:[[NSBundle mainBundle] pathForResource:@"bootstrap" ofType:@"coffee"]];
    
    [self watchConfigFiles];
}

- (void) reloadConfigIfWatchEnabled {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AutoReloadConfigs"]) {
        // this (hopefully?) guards against there sometimes being 2 notifications in a row
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadConfig) object:nil];
        [self performSelector:@selector(reloadConfig) withObject:nil afterDelay:0.1];
    }
}

- (void) evalCoffeeFile:(NSString*)path {
    NSString* contents = [NSString stringWithContentsOfFile:[path stringByStandardizingPath]
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];
    [self evalString:contents asCoffee:YES];
}

- (void) reloadConfig {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* file = [self configFileToUse];
        
        if (!file) {
            [[SDAlertWindowController sharedAlertWindowController]
             show:@"Can't find either ~/.windowsapp.{coffee,js}\n\nMake one exist and try Reload Config again."
             delay:@7.0];
            return;
        }
        
        [[SDKeyBinder sharedKeyBinder] removeKeyBindings];
        
        if (![self require:file])
            return;
        
        NSArray* failures = [[SDKeyBinder sharedKeyBinder] finalizeNewKeyBindings];
        
        if ([failures count] > 0) {
            NSString* str = [@"The following hot keys could not be bound:\n\n" stringByAppendingString: [failures componentsJoinedByString:@"\n"]];
            [[SDLogWindowController sharedLogWindowController] show:str
                                                               type:SDLogMessageTypeError];
        }
        else {
            static BOOL loaded;
            [[SDAlertWindowController sharedAlertWindowController]
             show:[NSString stringWithFormat:@"%s %@", (loaded ? "Reloaded" : "Loaded"), file]
             delay:nil];
            loaded = YES;
        }
        
    });
}

- (BOOL) require:(NSString*)filename {
    filename = [filename stringByStandardizingPath];
    NSString* contents = [NSString stringWithContentsOfFile:filename
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];
    if (!contents)
        return NO;
    
    if ([filename hasSuffix:@".js"]) {
        [self evalString:contents asCoffee:NO];
    }
    else if ([filename hasSuffix:@".coffee"]) {
        [self evalString:contents asCoffee:YES];
    }
    
    return YES;
}

- (NSString*) evalString:(NSString*)str asCoffee:(BOOL)useCoffee {
    if (useCoffee)
        return [self evalString:[self.jscocoa callFunction:@"coffeeToJS" withArguments:@[str]]
                       asCoffee:NO];
    else
        return [[self.jscocoa eval:str] description];
}

- (void) JSCocoa:(JSCocoaController*)controller hadError:(NSString*)error onLineNumber:(NSInteger)lineNumber atSourceURL:(id)url {
    NSString* msg = [NSString stringWithFormat: @"Error in config file on line: %ld\n\n%@", lineNumber, error];
    [[SDLogWindowController sharedLogWindowController] show:msg type:SDLogMessageTypeError];
}

- (void) watchConfigFiles {
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

- (NSString*) configFileToUse {
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
