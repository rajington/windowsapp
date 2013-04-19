//
//  SDConfigProblemReporter.m
//  Windows
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDLogWindowController.h"

#import <WebKit/WebKit.h>

#import "SDConfigLoader.h"

@interface SDLogWindowController ()

@property IBOutlet WebView* webView;
@property (copy) dispatch_block_t beforeReady;
@property BOOL ready;
@property BOOL hasContent;

@end

@implementation SDLogWindowController

+ (SDLogWindowController*) sharedLogWindowController {
    static SDLogWindowController* sharedMessageWindowController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMessageWindowController = [[SDLogWindowController alloc] init];
    });
    return sharedMessageWindowController;
}

- (NSString*) windowNibName {
    return @"LogWindow";
}

- (IBAction) evalFromRepl:(id)sender {
    NSString* str = [[SDConfigLoader sharedConfigLoader] evalString:[sender stringValue]];
    [self show:str type:SDLogMessageTypeREPL];
    [sender setStringValue:@""];
}

- (IBAction) clearLog:(id)sender {
    DOMDocument* doc = [self.webView mainFrameDocument];
    [doc body].innerHTML = @"";
    
    self.hasContent = NO;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    self.ready = YES;
    
    if (self.beforeReady) {
        self.beforeReady();
        self.beforeReady = nil;
    }
}

- (void) windowDidBecomeKey:(NSNotification *)notification {
    self.window.level = NSNormalWindowLevel;
}

- (void) windowDidLoad {
    self.webView.frameLoadDelegate = self;
    
    NSURL* path = [[NSBundle mainBundle] URLForResource:@"logwindow" withExtension:@"html"];
    NSString* html = [NSString stringWithContentsOfURL:path encoding:NSUTF8StringEncoding error:NULL];
    [[self.webView mainFrame] loadHTMLString:html baseURL:[NSURL URLWithString:@""]];
    
    [[self window] center];
}

- (void) doWhenReady:(dispatch_block_t)blk {
    if (self.ready)
        blk();
    else
        self.beforeReady = blk;
}

- (void) show:(NSString*)message type:(NSString*)type {
    self.window.level = NSFloatingWindowLevel;
    [self showWindow:nil];
    
    [self doWhenReady:^{
        DOMDocument* doc = [self.webView mainFrameDocument];
        
        if (self.hasContent) {
            DOMHTMLHRElement* hr = (id)[doc createElement:@"hr"];
            [[doc body] appendChild:hr];
        }
        
        NSString* classname = [@{SDLogMessageTypeError: @"error",
                               SDLogMessageTypeUser: @"user",
                               SDLogMessageTypeREPL: @"repl"} objectForKey:type];
        
        NSDateFormatter* stampFormatter = [[NSDateFormatter alloc] init];
        stampFormatter.dateStyle = NSDateFormatterNoStyle;
        stampFormatter.timeStyle = NSDateFormatterShortStyle;
        
        DOMHTMLElement* stamp = (id)[doc createElement:@"small"];
        stamp.innerText = [stampFormatter stringFromDate:[NSDate date]];
        [[doc body] appendChild:stamp];
        
        DOMHTMLParagraphElement* p = (id)[doc createElement:@"p"];
        p.innerText = message;
        p.className = classname;
        [[doc body] appendChild:p];
        
        [[self.webView windowScriptObject] evaluateWebScript:@"window.scrollTo(0, document.body.scrollHeight);"];
        
        self.hasContent = YES;
    }];
}

@end
