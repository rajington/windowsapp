//
//  SDAppProxy.h
//  Windows
//
//  Created by Steven on 4/21/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDAppProxy : NSObject

- (id) initWithPID:(pid_t)pid;
- (id) initWithRunningApp:(NSRunningApplication*)app;

+ (NSArray*) runningApps;

- (NSArray*) windows;
- (NSString*) title;
- (BOOL) isHidden;

@property (readonly) pid_t pid;

- (void) kill;
- (void) kill9;

- (void) startObservingStuff;
- (void) stopObservingStuff;

@end
