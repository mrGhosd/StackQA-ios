//
//  SidebarTableViewCell.h
//  StackQA
//
//  Created by vsokoltsov on 31.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SidebarTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *cellImage;
@property (strong, nonatomic) IBOutlet UILabel *cellLabel;

@end
