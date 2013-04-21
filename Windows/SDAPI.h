//
//  SDAPI.h
//  Windows
//
//  Created by Steven on 4/15/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <JSCocoa/JSCocoa.h>

#import "SDWindowProxy.h"
#import "SDScreenProxy.h"

@interface SDAPISettings : NSObject

@property CGFloat alertDisappearDelay;
@property BOOL alertAnimates;
- (NSBox*) alertBox;
- (NSTextField*) alertTextField;

@end

@interface SDAPI : NSObject

+ (SDAPISettings*) settings;

+ (NSDictionary*) shell:(NSString*)cmd args:(NSArray*)args input:(NSString*)input pwd:(NSString*)pwd;

@end
