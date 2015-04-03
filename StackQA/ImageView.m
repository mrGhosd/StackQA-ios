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
- (id) init{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [self.mainImage setUserInteractionEnabled:YES];
    [self.mainImage addGestureRecognizer:singleTap];
    return self;
}

- (void) tapDetected{
    if(self.actionView.hidden){
        self.actionView.hidden = NO;
    } else {
        self.actionView.hidden = YES;
    }
}

- (IBAction)removeImageView:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"hideImageView"
     object:self];
}
@end
