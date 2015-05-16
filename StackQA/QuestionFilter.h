//
//  QuestionFilter.h
//  StackQA
//
//  Created by vsokoltsov on 16.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "FilterDelegate.h"

@interface QuestionFilter : UIView
@property (nonatomic, weak) id<FilterDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *rateFilter;
@property (strong, nonatomic) IBOutlet UIButton *answersCountFilter;
@property (strong, nonatomic) IBOutlet UIButton *commentCountFilter;
@property (strong, nonatomic) IBOutlet UIButton *viewsCountFilter;
- (IBAction)filterByRate:(id)sender;
- (IBAction)filterByAnswer:(id)sender;
- (IBAction)filterByComment:(id)sender;
- (IBAction)filterByViews:(id)sender;

@end
