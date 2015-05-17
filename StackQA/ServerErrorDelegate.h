//
//  ServerErrorDelegate.h
//  StackQA
//
//  Created by vsokoltsov on 17.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//
@protocol ServerErrorDelegate <NSObject>

@optional
- (void) handleServerErrorWithError:(id) error;

@end
