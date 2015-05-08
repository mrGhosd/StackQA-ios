//
//  CategoryDetailViewController.m
//  StackQA
//
//  Created by vsokoltsov on 09.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "CategoryDetailViewController.h"

@interface CategoryDetailViewController (){
    float currentHeight;
}

@end

@implementation CategoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.categoryImage.image = [self.category categoryImage];
    self.categoryImage.layer.cornerRadius = self.categoryImage.frame.size.height / 2;
    self.categoryImage.layer.masksToBounds = YES;
    self.categoryTitle.text = self.category.title;
    [self.categoryText loadHTMLString:self.category.desc baseURL:nil];
    CGSize size = [self.category.desc sizeWithAttributes:nil];
    currentHeight = size.width / 10;
    if(currentHeight >= 100){
        self.webViewHeight.constant = currentHeight;
    }

    self.categoryText.scrollView.scrollEnabled = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
