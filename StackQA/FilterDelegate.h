//
//  QuestionFilterDelegate.h
//  StackQA
//
//  Created by vsokoltsov on 16.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

@protocol FilterDelegate <NSObject>

@optional
- (void) sortByRate;
- (void) sortByAnswer;
- (void) sortByComments;
- (void) sortByViews;

@end
