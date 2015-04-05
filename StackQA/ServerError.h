//
//  ServerError.h
//  StackQA
//
//  Created by vsokoltsov on 03.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerError : NSObject
@property (nonatomic) int *status;
@property (nonatomic, retain) NSHTTPURLResponse *failedResponse;
@property (nonatomic, retain) NSMutableDictionary *message;
- (instancetype) initWithData:(id) data;
- (instancetype) initWithError:(NSError *) error;
@end
