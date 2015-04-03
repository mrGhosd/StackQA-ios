//
//  ProfileSidebarTableViewCell.h
//  StackQA
//
//  Created by vsokoltsov on 31.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileSidebarTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *profileName;
@property (strong, nonatomic) IBOutlet UIButton *profileRate;
- (IBAction)showUserStatistic:(id)sender;

@end
