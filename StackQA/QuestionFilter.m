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
    [self.delegate sortByRate];
}

- (IBAction)filterByAnswer:(id)sender {
    [self.delegate sortByAnswer];
}

- (IBAction)filterByComment:(id)sender {
    [self.delegate sortByComments];
}

- (IBAction)filterByViews:(id)sender {
    [self.delegate sortByViews];
}
@end
