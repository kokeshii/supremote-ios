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
        
        // Set to JSON Because subsequent requests will be JSON
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        // Set access token, which also sets the Authorization token value on the request serializer.
        self.accessToken = [NSString stringWithFormat:@"Token %@", token];
        [self.requestSerializer setValue:self.accessToken forHTTPHeaderField:@"Authorization"];
        
        successBlock(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        errorBlock(error);
    }];
    
}


- (void) getProfileInformationWithSuccess:(objectBlock)successBlock error:(errorBlock)errorBlock {
    
    [self GET:@"me/" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        errorBlock(error);
    }];
    
}

- (void) getRemoteListWithSuccess:(objectBlock)successBlock error:(errorBlock)errorBlock {
    [self GET:@"remotes/" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        errorBlock(error);
    }];
}

- (void) saveRemoteValuesForRemoteWithId:(NSNumber *)remoteId values:(NSDictionary *)values success:(objectBlock)successBlock error:(errorBlock)errorBlock {
    
    [self POST:@"remotes/save-values/" parameters:values success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        errorBlock(error);
    }];
    
}

- (void) getRemoteWithId:(NSNumber *)remoteId success:(objectBlock)successBlock error:(errorBlock)errorBlock {
    
    NSString *path = [NSString stringWithFormat:@"remotes/%@/", remoteId];
    
    [self GET:path parameters:path success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        errorBlock(error);
    }];
    
}

- (void) triggerAction:(NSString *)actionName forRemoteWithId:(NSNumber *)remoteId success:(objectBlock)successBlock error:(errorBlock)errorBlock {
    
    NSDictionary *params = @{@"remote_id": remoteId, @"action_id": actionName};
    
    [self POST:@"remotes/trigger-action/" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        errorBlock(error);
    }];
    
}

@end
