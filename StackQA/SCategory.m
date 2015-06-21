//
//  SCategory.m
//  StackQA
//
//  Created by vsokoltsov on 10.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "SCategory.h"
#import "Api.h"

@implementation SCategory
- (instancetype) initWithParams: (NSDictionary *) params{
    if(self == [super init]){
        self.objectId = params[@"id"];
        self.title = params[@"title"];
        self.desc = params[@"description"];
        self.imageUrl = params[@"image"][@"url"];
    }
    return self;
}
- (UIImage *) categoryImage{
    UIImage *img  =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[Api sharedManager] returnCorrectUrlPrefix:self.imageUrl]]]];
    return img;
}
- (NSURL *) profileImageURL{
    return [NSURL URLWithString:[[Api sharedManager] returnCorrectUrlPrefix:self.imageUrl] ];
}
@end
