//
//  SPHTTPClient.h
//  Supremote
//
//  Created by Lambda Omega on 1/16/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

extern NSString * const SPHTTPClientLoggedOutNotification;

typedef void(^errorBlock)(NSError *errorInfo);
typedef void(^objectBlock)(id responseArray);

@interface SPHTTPClient : AFHTTPSessionManager

@property (strong, nonatomic) NSString *accessToken;

+ (instancetype)sharedClient;

- (void) loginWithUsername:(NSString *)username password:(NSString *)password success:(objectBlock)successBlock error:(errorBlock)errorBlock;

- (void) getProfileInformationWithSuccess:(objectBlock)successBlock error:(errorBlock)errorBlock;

- (void) getRemoteListWithSuccess:(objectBlock)successBlock error:(errorBlock)errorBlock;

- (void) saveRemoteValuesForRemoteWithId:(NSNumber *)remoteId values:(NSDictionary *)values success:(objectBlock)successBlock error:(errorBlock)errorBlock;

- (void) getRemoteWithId:(NSNumber *)remoteId success:(objectBlock)successBlock error:(errorBlock)errorBlock;

- (void) triggerAction:(NSString *)actionName forRemoteWithId:(NSNumber *)remoteId success:(objectBlock)successBlock error:(errorBlock)errorBlock;

- (void) logout;

- (void) checkForUnauthorizedResponse:(errorBlock)errorBlock error:(NSError *)error;

@end
