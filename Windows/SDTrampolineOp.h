//
//  AllWindowsOp.h
//  Windows
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Nu/Nu.h>

@interface SDTrampolineOp : NuOperator

@property (copy) id(^fn)(id cdr, NSMutableDictionary* ctx);

@end
