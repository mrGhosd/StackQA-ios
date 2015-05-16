//
//  QuestionFilter.m
//  StackQA
//
//  Created by vsokoltsov on 16.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "QuestionFilter.h"

@implementation QuestionFilter

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)filterByRate:(id)sender {
    self.rateFilter.highlighted = YES;
    [self.delegate sortByRate];
}

- (IBAction)filterByAnswer:(id)sender {
    self.answersCountFilter.highlighted = YES;
    [self.delegate sortByAnswer];
}

- (IBAction)filterByComment:(id)sender {
    self.commentCountFilter.highlighted = YES;
    [self.delegate sortByComments];
}

- (IBAction)filterByViews:(id)sender {
    self.viewsCountFilter.highlighted = YES;
    [self.delegate sortByViews];
}
@end
