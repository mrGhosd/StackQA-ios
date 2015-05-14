//
//  ServerConnection.h
//  StackQA
//
//  Created by vsokoltsov on 14.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^ResponseCopmlition)(id data, BOOL success);

@interface ServerConnection : NSObject
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *requestType;
@property (strong, nonatomic) NSDictionary *params;
- (void) startWithParams: (ResponseCopmlition) complition;
@end
