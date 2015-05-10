//
//  SCategory.h
//  StackQA
//
//  Created by vsokoltsov on 10.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SCategory : NSObject
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * objectId;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSMutableArray *questions;
- (instancetype) initWithParams: (NSDictionary *) params;
- (UIImage *) categoryImage;
@end
