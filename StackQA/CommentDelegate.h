//
//  CommentDelegate.h
//  StackQA
//
//  Created by vsokoltsov on 13.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

@protocol CommentDelegate <NSObject>

@optional
- (void) createCallbackWithParams:(NSDictionary *) params andSuccess: (BOOL) success;
- (void) destroyCallback: (BOOL) success path:(NSIndexPath *) path;
- (void) updateWithParams:(NSDictionary *) params path:(NSIndexPath *) path andSuccess:(BOOL) success;

@end
