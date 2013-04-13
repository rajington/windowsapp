//
//  AllWindowsOp.m
//  Windows
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDTrampolineOp.h"

@implementation SDTrampolineOp

- (id) callWithArguments:(id) cdr context:(NSMutableDictionary *) context {
    if (self.fn)
        return self.fn(cdr, context);
    else
        return nil;
}

@end
