//
//  ImageView.m
//  StackQA
//
//  Created by vsokoltsov on 03.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ImageView.h"

@implementation ImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)removeImageView:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"hideImageView"
     object:self];
}
@end
