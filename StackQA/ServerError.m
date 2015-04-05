//
//  ServerError.m
//  StackQA
//
//  Created by vsokoltsov on 03.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ServerError.h"

@implementation ServerError
- (instancetype) initWithData:(id) data{
    self = [super init];
    [self convertFromDataToError:data];
    return self;
}
- (instancetype) initWithError:(NSError *) error{
    self = [super init];
    [self parseError:error];
    return self;
}
- (void) convertFromDataToError:(id) data{
    NSError *error = (NSError *) data;
    [self parseError:error];
}
- (void) parseError:(NSError *) error{
    NSError *jsonError = nil;
    NSDictionary *userErrors = error.userInfo;
    NSDictionary* errorText = [NSJSONSerialization JSONObjectWithData:userErrors[@"com.alamofire.serialization.response.error.data"] options:kNilOptions error:&jsonError];
    NSHTTPURLResponse *response = userErrors[@"com.alamofire.serialization.response.error.response"];
    self.failedResponse = response;
    self.message = [NSMutableDictionary dictionaryWithDictionary:errorText];
    self.status = response.statusCode;
}
@end
