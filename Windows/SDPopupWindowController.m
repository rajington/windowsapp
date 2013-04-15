//
//  SDPopupWindowController.m
//  Windows
//
//  Created by Steven on 4/14/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDPopupWindowController.h"

#import <QuartzCore/QuartzCore.h>

@interface SDPopupWindowController ()

@property IBOutlet NSTextField* msgTextField;
@property IBOutlet NSBox* box;

//@property BOOL shouldBeVisible;

@end

@implementation SDPopupWindowController

- (NSString*) windowNibName {
    return @"PopupWindow";
}

- (void) windowDidLoad {
    self.disappearDelay = 1.0;
    self.window.ignoresMouseEvents = YES;
}

- (void) show:(NSString*)oneLineMsg {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeWindowOut) object:nil];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(closeAndResetWindow) object:nil];
    
    [self closeAndResetWindow];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.01];
    [[[self window] animator] setAlphaValue:1.0];
    [NSAnimationContext endGrouping];
    
    [self useTitleAndResize:[oneLineMsg description]];
    
    [self.window center];
    [self showWindow:self];
    
    [self performSelector:@selector(fadeWindowOut) withObject:nil afterDelay:self.disappearDelay];
}

- (void) fadeWindowOut {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.5];
    [[[self window] animator] setAlphaValue:0.0];
    [NSAnimationContext endGrouping];
    
    [self performSelector:@selector(closeAndResetWindow) withObject:nil afterDelay:0.5];
}

- (void) closeAndResetWindow {
    [[self window] orderOut:nil];
    [[self window] setAlphaValue:1.0];
}

- (void) useTitleAndResize:(NSString*)title {
    [self window]; // sigh; required in case nib hasnt loaded yet
    
    self.msgTextField.stringValue = title;
    [self.msgTextField sizeToFit];
    
	NSRect windowFrame = [[self window] frame];
	windowFrame.size.width = [self.msgTextField frame].size.width + 32.0;
	windowFrame.size.height = [self.msgTextField frame].size.height + 24.0;
	[[self window] setFrame:windowFrame display:YES];
}

@end
