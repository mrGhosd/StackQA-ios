//
//  RatingDelegate.h
//  StackQA
//
//  Created by vsokoltsov on 11.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

@protocol RatingDelegate <NSObject>

- (void) successRateCallbackWithData:(id) data;
- (void) failedRateCallbackWithData: (NSError *) error;

@end
