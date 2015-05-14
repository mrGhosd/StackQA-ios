//
//  ServerConnection.m
//  StackQA
//
//  Created by vsokoltsov on 14.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ServerConnection.h"
#import <AFNetworking.h>
#define MAIN_URL @"http://localhost:3000"

@implementation ServerConnection
@synthesize url;
@synthesize requestType;
@synthesize params;
- (void) startWithParams: (ResponseCopmlition) complition{
    ResponseCopmlition response = [complition copy];
    NSMutableURLRequest *request = [[[AFJSONRequestSerializer new] requestWithMethod:requestType
                                                                           URLString:[NSString stringWithFormat: @"%@/api/v1%@", MAIN_URL, url]
                                                                          parameters: params
                                                                               error:nil] mutableCopy];
    
    AFHTTPRequestOperation *requestAPI = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer new];
    serializer.readingOptions = NSJSONReadingAllowFragments;
    requestAPI.responseSerializer = serializer;
    
    [requestAPI setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        response(responseObject, YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        response(error, NO);
    }];
    
    [requestAPI start];
}
@end
