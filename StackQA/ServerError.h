//
//  ServerError.h
//  StackQA
//
//  Created by vsokoltsov on 03.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerErrorDelegate.h"

@interface ServerError : NSObject
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, retain) NSHTTPURLResponse *failedResponse;
@property (nonatomic, retain) NSMutableDictionary *message;
@property (nonatomic, retain) NSString *messageText;
@property (nonatomic, weak) id<ServerErrorDelegate> delegate;
- (instancetype) initWithData:(id) data;
- (instancetype) initWithError:(NSError *) error;
- (void) handle;
- (void) callErrorHAndlerWithoutData;
@end
