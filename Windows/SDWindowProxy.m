//
//  MyWindow.m
//  Windows
//
//  Created by Steven Degutis on 2/28/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDWindowProxy.h"

#import "NSScreen+RealFrame.h"

#import "SDUniversalAccessHelper.h"

@interface SDWindowProxy ()

@property CFTypeRef window;

@end

@implementation SDWindowProxy

+ (NSArray*) allWindows {
    if ([SDUniversalAccessHelper complainIfNeeded])
        return nil;
    
    NSMutableArray* windows = [NSMutableArray array];
    
    for (NSRunningApplication* runningApp in [[NSWorkspace sharedWorkspace] runningApplications]) {
//        if ([runningApp activationPolicy] == NSApplicationActivationPolicyRegular) {
            AXUIElementRef app = AXUIElementCreateApplication([runningApp processIdentifier]);
            
            CFArrayRef _windows;
            AXError result = AXUIElementCopyAttributeValues(app, kAXWindowsAttribute, 0, 100, &_windows);
            if (result == kAXErrorSuccess) {
                for (NSInteger i = 0; i < CFArrayGetCount(_windows); i++) {
                    AXUIElementRef win = CFArrayGetValueAtIndex(_windows, i);
                    SDWindowProxy* window = [[SDWindowProxy alloc] init];
                    window.window = CFRetain(win);
                    [windows addObject:window];
                }
                CFRelease(_windows);
            }
            
            CFRelease(app);
//        }
    }
    
    return windows;
}

+ (NSArray*) visibleWindows {
    if ([SDUniversalAccessHelper complainIfNeeded])
        return nil;
    
    return [[self allWindows] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SDWindowProxy* win, NSDictionary *bindings) {
        return ![win isAppHidden]
        && ![win isWindowMinimized]
        && [[win subrole] isEqualToString: (__bridge NSString*)kAXStandardWindowSubrole];
    }]];
}

- (NSArray*) otherWindowsOnSameScreen {
    return [[SDWindowProxy visibleWindows] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SDWindowProxy* win, NSDictionary *bindings) {
        return !CFEqual(self.window, win.window) && [[self screen] isEqual: [win screen]];
    }]];
}

- (void) dealloc {
    if (self.window)
        CFRelease(self.window);
}

+ (AXUIElementRef) systemWideElement {
    static AXUIElementRef systemWideElement;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        systemWideElement = AXUIElementCreateSystemWide();
    });
    return systemWideElement;
}

+ (SDWindowProxy*) focusedWindow {
    if ([SDUniversalAccessHelper complainIfNeeded])
        return nil;
    
    CFTypeRef app;
    AXUIElementCopyAttributeValue([self systemWideElement], kAXFocusedApplicationAttribute, &app);
    
    CFTypeRef win;
    AXError result = AXUIElementCopyAttributeValue(app, (CFStringRef)NSAccessibilityFocusedWindowAttribute, &win);
    CFRelease(app);
    
    if (result == kAXErrorSuccess) {
        SDWindowProxy* window = [[SDWindowProxy alloc] init];
        window.window = win;
        return window;
    }
    
    return nil;
}

- (void) moveToFrame:(CGRect)frame onScreen:(NSScreen*)screen {
    CGRect screenRect = [screen frameInWindowCoordinates];
    
    frame.origin.x += NSMinX(screenRect);
    frame.origin.y += NSMinY(screenRect);
    
    frame = NSIntegralRect(frame);
    
    [self setFrame:frame];
}

- (CGRect) frame {
    CGRect r;
    r.origin = [self topLeft];
    r.size = [self size];
    return r;
}

- (void) setFrame:(CGRect)frame {
    [self setSize:frame.size];
    [self setTopLeft:frame.origin];
    [self setSize:frame.size];
}

- (CGPoint) topLeft {
    CFTypeRef positionStorage;
    AXError result = AXUIElementCopyAttributeValue(self.window, (CFStringRef)NSAccessibilityPositionAttribute, &positionStorage);
    
    CGPoint topLeft;
    if (result == kAXErrorSuccess) {
        if (!AXValueGetValue(positionStorage, kAXValueCGPointType, (void *)&topLeft)) {
            NSLog(@"could not decode topLeft");
            topLeft = CGPointZero;
        }
    }
    else {
        NSLog(@"could not get window topLeft");
        topLeft = CGPointZero;
    }
    
    if (positionStorage)
        CFRelease(positionStorage);
    
    return topLeft;
}

- (CGSize) size {
    CFTypeRef sizeStorage;
    AXError result = AXUIElementCopyAttributeValue(self.window, (CFStringRef)NSAccessibilitySizeAttribute, &sizeStorage);
    
    CGSize size;
    if (result == kAXErrorSuccess) {
        if (!AXValueGetValue(sizeStorage, kAXValueCGSizeType, (void *)&size)) {
            NSLog(@"could not decode topLeft");
            size = CGSizeZero;
        }
    }
    else {
        NSLog(@"could not get window size");
        size = CGSizeZero;
    }
    
    if (sizeStorage)
        CFRelease(sizeStorage);
    
    return size;
}

- (void) setTopLeft:(CGPoint)thePoint {
    CFTypeRef positionStorage = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&thePoint));
    AXUIElementSetAttributeValue(self.window, (CFStringRef)NSAccessibilityPositionAttribute, positionStorage);
    if (positionStorage)
        CFRelease(positionStorage);
}

- (void) setSize:(CGSize)theSize {
    CFTypeRef sizeStorage = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&theSize));
    AXUIElementSetAttributeValue(self.window, (CFStringRef)NSAccessibilitySizeAttribute, sizeStorage);
    if (sizeStorage)
        CFRelease(sizeStorage);
}

- (NSScreen*) screen {
    CGRect windowFrame = [self frame];
    
    CGFloat lastVolume = 0;
    NSScreen* lastScreen = nil;
    
    for (NSScreen* screen in [NSScreen screens]) {
        CGRect screenFrame = [screen frameInWindowCoordinates];
        CGRect intersection = CGRectIntersection(windowFrame, screenFrame);
        CGFloat volume = intersection.size.width * intersection.size.height;
        
        if (volume > lastVolume) {
            lastVolume = volume;
            lastScreen = screen;
        }
    }
    
    return lastScreen;
}

- (void) moveToNextScreen {
    NSArray* screens = [NSScreen screens];
    NSScreen* currentScreen = [self screen];
    
    NSUInteger idx = [screens indexOfObject:currentScreen];
    
    idx += 1;
    if (idx == [screens count])
        idx = 0;
    
    NSScreen* nextScreen = [screens objectAtIndex:idx];
    [self moveToFrame:[self frame] onScreen:nextScreen];
}

- (void) moveToPreviousScreen {
    NSArray* screens = [NSScreen screens];
    NSScreen* currentScreen = [self screen];
    
    NSUInteger idx = [screens indexOfObject:currentScreen];
    
    idx -= 1;
    if (idx == -1)
        idx = [screens count] - 1;
    
    NSScreen* nextScreen = [screens objectAtIndex:idx];
    [self moveToFrame:[self frame] onScreen:nextScreen];
}

- (void) maximize {
    CGRect screenRect = [[self screen] frameInWindowCoordinates];
    [self setFrame:screenRect];
}

- (BOOL) focusWindow {
    AXError changedMainWindowResult = AXUIElementSetAttributeValue(self.window, (CFStringRef)NSAccessibilityMainAttribute, kCFBooleanTrue);
    if (changedMainWindowResult != kAXErrorSuccess) {
        NSLog(@"ERROR: Could not change focus to window");
        return NO;
    }
    
    ProcessSerialNumber psn;
    GetProcessForPID([self processIdentifier], &psn);
    OSStatus focusAppResult = SetFrontProcessWithOptions(&psn, kSetFrontProcessFrontWindowOnly);
    return focusAppResult == 0;
}

- (pid_t) processIdentifier {
    pid_t pid = 0;
    AXError result = AXUIElementGetPid(self.window, &pid);
    if (result == kAXErrorSuccess)
        return pid;
    else
        return 0;
}

- (BOOL) isAppHidden {
    AXUIElementRef app = AXUIElementCreateApplication([self processIdentifier]);
    if (app == NULL)
        return YES;
    
    CFTypeRef _isHidden;
    BOOL isHidden = NO;
    if (AXUIElementCopyAttributeValue(app, (CFStringRef)NSAccessibilityHiddenAttribute, (CFTypeRef *)&_isHidden) == kAXErrorSuccess) {
        NSNumber *isHiddenNum = CFBridgingRelease(_isHidden);
        isHidden = [isHiddenNum boolValue];
    }
    
    CFRelease(app);
    
    return isHidden;
}

- (id) getWindowProperty:(NSString*)propType withDefaultValue:(id)defaultValue {
    CFTypeRef _someProperty;
    if (AXUIElementCopyAttributeValue(self.window, (__bridge CFStringRef)propType, &_someProperty) == kAXErrorSuccess)
        return CFBridgingRelease(_someProperty);
    
    return defaultValue;
}

- (NSString *) title {
    return [self getWindowProperty:NSAccessibilityTitleAttribute withDefaultValue:@""];
}

- (NSString *) role {
    return [self getWindowProperty:NSAccessibilityRoleAttribute withDefaultValue:@""];
}

- (NSString *) subrole {
    return [self getWindowProperty:NSAccessibilitySubroleAttribute withDefaultValue:@""];
}

- (BOOL) isWindowMinimized {
    return [[self getWindowProperty:NSAccessibilityMinimizedAttribute withDefaultValue:@(NO)] boolValue];
}

// focus


NSPoint SDMidpoint(NSRect r) {
    return NSMakePoint(NSMidX(r), NSMidY(r));
}

- (NSArray*) windowsInDirectionFn:(double(^)(double angle))whichDirectionFn
                shouldDisregardFn:(BOOL(^)(double deltaX, double deltaY))shouldDisregardFn
{
    SDWindowProxy* thisWindow = [SDWindowProxy focusedWindow];
    NSPoint startingPoint = SDMidpoint([thisWindow frame]);
    
    NSArray* otherWindows = [thisWindow otherWindowsOnSameScreen];
    NSMutableArray* closestOtherWindows = [NSMutableArray arrayWithCapacity:[otherWindows count]];
    
    for (SDWindowProxy* win in otherWindows) {
        NSPoint otherPoint = SDMidpoint([win frame]);
        
        double deltaX = otherPoint.x - startingPoint.x;
        double deltaY = otherPoint.y - startingPoint.y;
        
        if (shouldDisregardFn(deltaX, deltaY))
            continue;
        
        double angle = atan2(deltaY, deltaX);
        double distance = hypot(deltaX, deltaY);
        
        double angleDifference = whichDirectionFn(angle);
        
        double score = distance / cos(angleDifference / 2.0);
        
        [closestOtherWindows addObject:@{
         @"score": @(score),
         @"win": win,
         }];
    }
    
    NSArray* sortedOtherWindows = [closestOtherWindows sortedArrayUsingComparator:^NSComparisonResult(NSDictionary* pair1, NSDictionary* pair2) {
        return [[pair1 objectForKey:@"score"] compare: [pair2 objectForKey:@"score"]];
    }];
    
    return sortedOtherWindows;
}

- (void) focusFirstValidWindowIn:(NSArray*)closestWindows {
    for (SDWindowProxy* win in [closestWindows valueForKeyPath:@"win"]) {
        if ([win focusWindow])
            break;
    }
}

- (void) focusWindowLeft {
    NSArray* closestWindows = [self windowsInDirectionFn:^double(double angle) { return M_PI - abs(angle); }
                                       shouldDisregardFn:^BOOL(double deltaX, double deltaY) { return (deltaX >= 0); }];
    
    [self focusFirstValidWindowIn:closestWindows];
}

- (void) focusWindowRight {
    NSArray* closestWindows = [self windowsInDirectionFn:^double(double angle) { return 0.0 - angle; }
                                       shouldDisregardFn:^BOOL(double deltaX, double deltaY) { return (deltaX <= 0); }];
    
    [self focusFirstValidWindowIn:closestWindows];
}

- (void) focusWindowUp {
    NSArray* closestWindows = [self windowsInDirectionFn:^double(double angle) { return -M_PI_2 - angle; }
                                       shouldDisregardFn:^BOOL(double deltaX, double deltaY) { return (deltaY >= 0); }];
    
    [self focusFirstValidWindowIn:closestWindows];
}

- (void) focusWindowDown {
    NSArray* closestWindows = [self windowsInDirectionFn:^double(double angle) { return M_PI_2 - angle; }
                                       shouldDisregardFn:^BOOL(double deltaX, double deltaY) { return (deltaY <= 0); }];
    
    [self focusFirstValidWindowIn:closestWindows];
}

@end
