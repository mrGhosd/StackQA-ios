//
//  UserCommentTableViewCell.m
//  StackQA
//
//  Created by vsokoltsov on 08.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "UserCommentTableViewCell.h"

@implementation UserCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void) setParametersForComment:(Comment *) comment{
    self.commentText.editable = NO;
    self.commentText.scrollEnabled = NO;
    self.commentText.text = comment.text;
    self.commentEntityLink.tag = [comment.objectId integerValue];
    id entity = [comment getParentEntity];
    NSString *buttonTitle;
    UIImage *buttonImage;
    if([comment.commentableType isEqualToString:@"Question"]){
        buttonTitle = [entity title];
        buttonImage = [UIImage imageNamed:@"ask_question-32.png"];
    } else {
        buttonTitle = [entity text];
        buttonImage = [UIImage imageNamed:@"answers-32.png"];
    }
    [self.commentEntityLink setTitle:buttonTitle forState:UIControlStateNormal];
    [self.commentEntityLink setImage:buttonImage forState:UIControlStateNormal];
}

@end
