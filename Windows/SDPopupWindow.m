//
//  SDPopupWindow.m
//  Windows
//
//  Created by Steven on 4/14/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDPopupWindow.h"

@implementation SDPopupWindow

- (id) initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	if (self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag]) {
		[self setBackgroundColor:[NSColor clearColor]];
		[self setOpaque:NO];
		[self setLevel:NSFloatingWindowLevel];
        [self setAnimationBehavior:NSWindowAnimationBehaviorAlertPanel];
//        [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorStationary];
	}
	return self;
}

@end
