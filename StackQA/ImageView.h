//
//  ImageView.h
//  StackQA
//
//  Created by vsokoltsov on 03.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageView : UIView
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UIImageView *mainImage;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;
- (IBAction)removeImageView:(id)sender;

@end
