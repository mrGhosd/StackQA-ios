//
//  Api.m
//  StackQA
//
//  Created by vsokoltsov on 09.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "Api.h"
#import <Foundation/Foundation.h>
#import "AuthorizationManager.h"
#import <UICKeyChainStore.h>
#import "ServerError.h"

#define MAIN_URL @"http://localhost:3000"
@implementation Api{
    AuthorizationManager *auth;
    UICKeyChainStore *store;
}

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

- (void) getData: (NSString *) url andComplition:(ResponseCopmlition) complition{
    store = [UICKeyChainStore keyChainStore];
    NSDictionary *params = [[NSDictionary alloc] init];
    if([store objectForKeyedSubscript:@"access_token"]){
        params = @{@"access_token": [store objectForKeyedSubscript:@"access_token"]};
    } else {
        params = nil;
    }
    ResponseCopmlition response = [complition copy];
    NSMutableURLRequest *request = [[[AFJSONRequestSerializer new] requestWithMethod:@"GET"
                                                                           URLString:[NSString stringWithFormat: @"%@/api/v1%@", MAIN_URL, url]
                                                                          parameters: params
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

- (void) sendDataToURL:(NSString *) url parameters: (NSMutableDictionary *)params requestType:(NSString *)type andComplition:(ResponseCopmlition) complition{
    NSMutableDictionary *copiedParams = [params mutableCopy];
    params = [[NSMutableDictionary alloc] init];
    ResponseCopmlition response = [complition copy];
    store = [UICKeyChainStore keyChainStore];
    if([store objectForKeyedSubscript:@"access_token"]){
        NSMutableDictionary *accessToken = @{@"access_token": [store objectForKeyedSubscript:@"access_token"]};
        [params addEntriesFromDictionary:copiedParams];
        [params addEntriesFromDictionary:accessToken];
    }
    NSString *userLocale = [[NSLocale preferredLanguages] objectAtIndex:0];
    [params addEntriesFromDictionary:@{@"device_locale": userLocale}];
    NSMutableURLRequest *request = [[[AFJSONRequestSerializer new] requestWithMethod:type
                                                                           URLString:[NSString stringWithFormat: @"%@/api/v1%@", MAIN_URL, url]
                                                                          parameters: params
                                                                               error:nil] mutableCopy];
    
    AFHTTPRequestOperation *requestAPI = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer new];
    serializer.readingOptions = NSJSONReadingAllowFragments;
    requestAPI.responseSerializer = serializer;
    
    [requestAPI setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        response(responseObject, YES);
        self.lastSyncDate = [NSDate date];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *errorDict = @{@"operation": operation, @"error": error};
        response(errorDict, NO);
    }];
    
    [requestAPI start];
}

- (void) getTokenWithParameters:(NSDictionary *)params andComplition:(ResponseCopmlition) complition{
    ResponseCopmlition response = [complition copy];
    NSMutableURLRequest *request = [[[AFJSONRequestSerializer new] requestWithMethod:@"POST"
                                                                           URLString:[NSString stringWithFormat: @"%@/oauth/token", MAIN_URL]
                                                                          parameters: params
                                                                               error:nil] mutableCopy];
    
    AFHTTPRequestOperation *requestAPI = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer new];
    serializer.readingOptions = NSJSONReadingAllowFragments;
    requestAPI.responseSerializer = serializer;
    
    [requestAPI setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        response(responseObject, YES);
        self.lastSyncDate = [NSDate date];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *errorDict = @{@"operation": operation, @"error": error};
        response(errorDict, NO);
    }];
    
    [requestAPI start];
}
- (NSString *)returnCorrectUrlPrefix:(NSString *)string{
    return [NSString stringWithFormat:@"%@%@", MAIN_URL, string];
}
@end
