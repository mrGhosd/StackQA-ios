//
//  Api.h
//  StackQA
//
//  Created by vsokoltsov on 09.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
typedef void(^ResponseCopmlition)(id data, BOOL success);
typedef void (^requestCompletedBlock)(id);
typedef void(^requestErrorBlock)(NSError *);

@interface Api : NSObject

@property (nonatomic, copy) requestCompletedBlock completed;
@property (nonatomic, copy) requestErrorBlock errored;
@property (nonatomic, copy) NSDate *lastSyncDate;

+ (id) sharedManager;
- (void) getData: (NSString *) url andComplition:(ResponseCopmlition) complition;
- (void) sendDataToURL:(NSString *) url parameters: (NSDictionary *)params requestType:(NSString *)type andComplition:(ResponseCopmlition) complition;
- (void) getTokenWithParameters:(NSDictionary *)params andComplition:(ResponseCopmlition) complition;
- (NSString *)returnCorrectUrlPrefix:(NSString *)string;
@end
