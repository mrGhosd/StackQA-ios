//
//  UserCommentTableViewCell.h
//  StackQA
//
//  Created by vsokoltsov on 08.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import <SWTableViewCell.h>

@interface UserCommentTableViewCell : SWTableViewCell
@property (strong, nonatomic) IBOutlet UIButton *commentEntityLink;
@property (strong, nonatomic) IBOutlet UITextView *commentText;
- (void) setParametersForComment:(Comment *) comment;
@end
