//
//  AnswerDelegate.h
//  StackQA
//
//  Created by vsokoltsov on 12.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

@protocol AnswerDelegate <NSObject>

@optional
- (void) createCallbackWithParams:(NSDictionary *) params andSuccess: (BOOL) success;
- (void) destroyCallback: (BOOL) success path: (NSIndexPath *) path;
- (void) changeRateCallbackWithParams:(NSDictionary *) params path:(NSIndexPath *) path andSuccess: (BOOL) success;
- (void) markAsHelpfullCallbackWithParams:(NSDictionary *) params path:(NSIndexPath *)path andSuccess: (BOOL) success;
- (void) updateWithParams:(NSDictionary *) params andSuccess:(BOOL) success;
- (void) complaintToAnswerWithSuccess: (BOOL) success andIndexPath: (NSIndexPath *) path;
@end