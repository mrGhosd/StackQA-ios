//
//  CacheRequest.m
//  StackQA
//
//  Created by vsokoltsov on 21.06.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "CacheRequest.h"

@implementation CacheRequest
+ (id) sharedInstance{
    static CacheRequest *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[self alloc] init];
        cache.cachedData = [NSMutableDictionary new];
    });
    return cache;
}
@end
