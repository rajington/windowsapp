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

+ (SDMessageWindowController*) sharedMessageWindowController {
    static SDMessageWindowController* sharedMessageWindowController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMessageWindowController = [[SDMessageWindowController alloc] init];
    });
    return sharedMessageWindowController;
}

- (NSString*) windowNibName {
    return @"MessageWindow";
}

- (void) windowDidLoad {
    [self.textView setFont:[NSFont fontWithName:@"Menlo" size:11.0]];
    
    self.window.level = NSFloatingWindowLevel;
    [[self window] center];
}

- (void) show:(NSString*)message {
    if (self.window.isVisible) {
        self.message = [NSString stringWithFormat:@"%@\n\n\n%@", self.message, message];
        [self.textView scrollToEndOfDocument:self];
    }
    else {
        self.message = message;
    }
    
    [self showWindow:nil];
}

@end
