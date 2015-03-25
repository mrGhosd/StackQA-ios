//
//  AuthorizationViewController.h
//  StackQA
//
//  Created by vsokoltsov on 26.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthorizationViewController : UIViewController
@property(nonatomic, retain) NSString *firstView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@end
