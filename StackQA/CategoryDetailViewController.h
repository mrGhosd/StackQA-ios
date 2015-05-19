//
//  CategoryDetailViewController.h
//  StackQA
//
//  Created by vsokoltsov on 09.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ViewController.h"
#import "SCategory.h"

@interface CategoryDetailViewController : ViewController <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *categoryImage;
@property (strong, nonatomic) IBOutlet UILabel *categoryTitle;
@property (strong, nonatomic) IBOutlet UIWebView *categoryText;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *webViewHeight;
@property (strong) SCategory *category;
@end
