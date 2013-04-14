//
//  SDConfigProblemReporter.m
//  Windows
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDMessageWindowController.h"

@interface SDMessageWindowController ()

@property NSString* message;
@property IBOutlet NSTextView* textView;

@end

@implementation SDMessageWindowController

- (NSString*) windowNibName {
    return @"MessageWindow";
}

- (void) windowDidLoad {
    [self.textView setFont:[NSFont fontWithName:@"Menlo" size:11.0]];
    
    self.window.level = NSFloatingWindowLevel;
    [[self window] center];
}

- (void) show:(NSString*)message {
    self.message = message;
    
    [self showWindow:nil];
}

@end
