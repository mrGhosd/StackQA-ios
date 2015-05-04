//
//  CommentTableViewCell.h
//  StackQA
//
//  Created by vsokoltsov on 04.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *userAvatar;
@property (strong, nonatomic) IBOutlet UITextView *commentText;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentTextHeight;
@property (strong, nonatomic) IBOutlet UIButton *userName;

@end
