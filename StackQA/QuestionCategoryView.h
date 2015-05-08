//
//  QuestionCategoryView.h
//  StackQA
//
//  Created by vsokoltsov on 09.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionCategoryView : UIView

@property (strong, nonatomic) IBOutlet UILabel *categoryTitle;

@property (strong, nonatomic) IBOutlet UIWebView *categoryWebView;
@property (strong, nonatomic) IBOutlet UIImageView *categoryImageView;
@end
