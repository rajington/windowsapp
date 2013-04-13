//
//  BindkeyOp.h
//  Windows
//
//  Created by Steven on 4/13/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Nu/Nu.h>

@interface BindkeyOp : NuOperator

- (void) removeKeyBindings;
- (void) finalizeNewKeyBindings;

@end
