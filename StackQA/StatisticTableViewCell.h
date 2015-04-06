//
//  StatisticTableViewCell.h
//  StackQA
//
//  Created by vsokoltsov on 07.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatisticTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;

@end
