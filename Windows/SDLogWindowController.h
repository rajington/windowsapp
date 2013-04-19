//
//  SDConfigProblemReporter.h
//  Windows
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SDLogWindowController : NSWindowController

+ (SDLogWindowController*) sharedLogWindowController;

- (void) show:(NSString*)message;

@end
