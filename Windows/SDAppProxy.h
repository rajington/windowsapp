//
//  SDAppProxy.h
//  Windows
//
//  Created by Steven on 4/21/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDAppProxy : NSObject

+ (NSArray*) runningApps;
- (id) initWithPID:(pid_t)pid;

- (NSArray*) windows;
- (NSString*) title;
- (BOOL) isHidden;

- (void) kill;
- (void) kill9;

@end
