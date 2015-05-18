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
    self.status = [NSNumber numberWithInteger:operation.response.statusCode];
    self.messageText = [error localizedDescription];
    NSDictionary *userInfo = [error userInfo];
    NSData *messageData = userInfo[@"com.alamofire.serialization.response.error.data"];
    if(messageData){
        NSError *errorJson=nil;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:messageData options:kNilOptions error:&errorJson];
        self.message = [NSMutableDictionary dictionaryWithDictionary:responseDict];
    }
    
}

- (void) callErrorHAndlerWithoutData{
    [self.delegate handleServerErrorWithError:self];
}

- (void) handle{
    if(self.status == @0){
        [self.delegate handleServerErrorWithError:self];
    } else if ([self.status isEqual:@422]){
        [self.delegate handleServerFormErrorWithError:self];
    }
}
@end
