//
//  SDPopupWindowController.h
//  Windows
//
//  Created by Steven on 4/14/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SDPopupWindowController : NSWindowController

@property NSInteger disappearDelay;

- (void) show:(NSString*)oneLineMsg;

@end
