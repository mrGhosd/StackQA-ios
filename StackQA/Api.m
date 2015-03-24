//
//  Api.m
//  StackQA
//
//  Created by vsokoltsov on 09.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "Api.h"
#import <Foundation/Foundation.h>

@implementation Api

static Api *sharedSingleton_ = nil;

@synthesize completed = _completed;
@synthesize errored = _errored;

+ (id) sharedManager{
    static Api *api = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        api = [[self alloc] init];
    });
    return api;
}

- (void) getTokenWithClientID:(NSString *) clientId andSecretID:(NSString *) secretID andComplition:(ResponseCopmlition) complition{
    ResponseCopmlition response = [complition copy];
    NSMutableURLRequest *request = [[[AFJSONRequestSerializer new] requestWithMethod:@"POST"
                                                                           URLString:@"http://localhost:3000/oauth/token"
                                                                          parameters:@{@"grant_type": @"password", @"email": @"vforvad@gmail.com", @"password": @"Altair_69"}
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

- (void) getData: (NSString *) url andComplition:(ResponseCopmlition) complition{
    ResponseCopmlition response = [complition copy];
    NSMutableURLRequest *request = [[[AFJSONRequestSerializer new] requestWithMethod:@"GET"
                                                                           URLString:[NSString stringWithFormat: @"http://localhost:3000/api/v1%@", url]
                                                                          parameters: nil
                                                                               error:nil] mutableCopy];
    
    AFHTTPRequestOperation *requestAPI = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer new];
    serializer.readingOptions = NSJSONReadingAllowFragments;
    requestAPI.responseSerializer = serializer;
    
    [requestAPI setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        response(responseObject, YES);
        self.lastSyncDate = [NSDate date];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        response(error, NO);
    }];
    
    [requestAPI start];
}
@end
