//
//  SDAppStalker.h
//  Windows
//
//  Created by Steven on 4/21/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SDWindowCreatedNotification @"SDWindowCreatedNotification"
#define SDAppLaunchedNotification @"SDAppLaunchedNotification"

@interface SDAppStalker : NSObject

+ (SDAppStalker*) sharedAppStalker;

- (void) beginStalking;

@end
