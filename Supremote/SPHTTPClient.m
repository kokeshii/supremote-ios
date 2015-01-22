//
//  SPHTTPClient.m
//  Supremote
//
//  Created by Lambda Omega on 1/16/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPHTTPClient.h"

#define DEV_OFFLINE_URL @"http://localhost:8111/api/"
#define DEV_ONLINE_URL @"https:/www.supremote.com/api/"

#define ROOT_URL DEV_OFFLINE_URL

NSString * const SPHTTPClientLoggedOutNotification = @"SPHTTPClientLoggedOutNotification";

@implementation SPHTTPClient

+ (instancetype)sharedClient {
    static SPHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SPHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:ROOT_URL]];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
    });
    
    return _sharedClient;
}



- (void) loginWithUsername:(NSString *)username password:(NSString *)password success:(objectBlock)successBlock error:(errorBlock)errorBlock {
    
    NSDictionary *params = @{@"username": username,  @"password": password};
    
    // Set to HTTP Request Serializer because we must login sending the credentials via form-data.
    
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [self POST:@"auth/" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *token = ((NSDictionary *)responseObject)[@"token"];
        
        self.accessToken = token;
        
        successBlock(token);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self checkForUnauthorizedResponse:errorBlock error:error];
    }];
    
}

- (void) setAccessToken:(NSString *)accessToken {
    // Set JSON Request serializer
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    // Set the access token iVar
    _accessToken = accessToken;
    // Set the HTTP header field.
    [self.requestSerializer
                            setValue:[NSString stringWithFormat:@"Token %@", accessToken]
                            forHTTPHeaderField:@"Authorization"];
}


- (void) getProfileInformationWithSuccess:(objectBlock)successBlock error:(errorBlock)errorBlock {
    
    [self GET:@"me/" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self checkForUnauthorizedResponse:errorBlock error:error];
    }];
    
}

- (void) getRemoteListWithSuccess:(objectBlock)successBlock error:(errorBlock)errorBlock {
    [self GET:@"remotes/" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self checkForUnauthorizedResponse:errorBlock error:error];
    }];
}

- (void) saveRemoteValuesForRemoteWithId:(NSNumber *)remoteId values:(NSDictionary *)values success:(objectBlock)successBlock error:(errorBlock)errorBlock {
    
    
    NSDictionary *params = @{
                             @"remote_id": remoteId,
                             @"values": values
                             };
    
    
    [self POST:@"remotes/save-values/" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self checkForUnauthorizedResponse:errorBlock error:error];
    }];
    
}

- (void) getRemoteWithId:(NSNumber *)remoteId success:(objectBlock)successBlock error:(errorBlock)errorBlock {
    
    NSString *path = [NSString stringWithFormat:@"remotes/%@/", remoteId];
    
    [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self checkForUnauthorizedResponse:errorBlock error:error];
    }];
    
}

- (void) triggerAction:(NSString *)actionName forRemoteWithId:(NSNumber *)remoteId success:(objectBlock)successBlock error:(errorBlock)errorBlock {
    
    NSDictionary *params = @{@"remote_id": remoteId, @"action_id": actionName};
    
    [self POST:@"remotes/trigger-action/" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self checkForUnauthorizedResponse:errorBlock error:error];
    }];
    
}


- (void) postLoggedOutNotification {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:SPHTTPClientLoggedOutNotification object:nil];
}

- (void) checkForUnauthorizedResponse:(errorBlock)errorBlock error:(NSError *)error {
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)error.userInfo[@"com.alamofire.serialization.response.error.response"];
    
    
    
    // If response is unauthorized, post the notification
    if (response.statusCode == 401) {
        NSLog(@"POST NOTIFICATION!!! LOGGED OUT!!");
        errorBlock(nil);
        [self postLoggedOutNotification];
    } else {
        errorBlock(error);
    }
    
    
    
}

- (void) logout {
    self.accessToken = nil;
}

@end
