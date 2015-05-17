//
//  ServerError.m
//  StackQA
//
//  Created by vsokoltsov on 03.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ServerError.h"
#import <AFNetworking.h>

@implementation ServerError
- (instancetype) initWithData:(id) data{
    if(self == [super init]){
        [self convertFromDataToError:data];
    }
    return self;
}

- (void) convertFromDataToError:(id) data{
    NSError *error = (NSError *) data[@"error"];
    AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *) data[@"operation"];
    [self parseErrorWithError:error andOperation:operation];
}
- (void) parseErrorWithError:(NSError *) error andOperation: (AFHTTPRequestOperation *) operation{
    self.status = operation.response.statusCode;
    self.messageText = [error localizedDescription];
}
- (void) handle{
    [self.delegate handleServerErrorWithError:self];
}
@end
