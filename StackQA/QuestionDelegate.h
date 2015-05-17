//
//  QuestionDelegate.h
//  StackQA
//
//  Created by vsokoltsov on 12.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

@protocol QuestionDelegate <NSObject>

@optional
- (void) successDestroyCallback;
- (void) failedDestroyCallback;
- (void) complainToQuestionWithData:(id) data andSuccess: (BOOL) success;
@end
