//
//  CacheRequest.h
//  StackQA
//
//  Created by vsokoltsov on 21.06.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheRequest : NSObject
@property (nonatomic, strong) NSMutableDictionary *cachedData;
+ (id) sharedInstance;
@end
