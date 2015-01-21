//
//  SPRemote.m
//  Supremote
//
//  Created by Lambda Omega on 1/20/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPRemote.h"

@interface SPRemote ()

@property (nonatomic, strong) NSDictionary *remote;
@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSDictionary *commitedValues;
@end

@implementation SPRemote


- (id) initWithDictionary:(NSDictionary *)dict {
    
    if (self = [super init]) {
        self.remote = dict;
        // Values is the buffer
        self.values = [dict[@"current_values"] mutableCopy];
        
        // Commited values is what we reset to when there's a rollback
        self.commitedValues = [dict[@"current_values"] copy];
    }
    
    return self;
    
}

+ (instancetype) remoteFromDictionary:(NSDictionary *)dictionary {
    
    return [[SPRemote alloc] initWithDictionary:dictionary];
}



- (void) commit {
    self.commitedValues = [NSDictionary dictionaryWithDictionary:self.values];
}

- (void) rollback {
    self.values = [self.commitedValues mutableCopy];
}

- (NSString *) name {
    return self.remote[@"name"];
}


- (NSNumber *) remoteId {
    return self.remote[@"id"];
}


- (NSInteger) fieldCount {
    return [self.remote[@"configuration"][@"fields"] count];
}

- (NSDictionary *) currentValues {
    return self.values;
}

- (id) getCurrentValueForKey:(NSString *)key {
    
    return self.values[key];
    
}

- (void) setCurrentValue:(id)value forKey:(NSString *)key {
    
    self.values[key] = value;
    
}

- (NSDictionary *) fieldForKey:(NSString *)key {
    return self.remote[@"configuration"][@"fields"][key];
}

- (SPRemoteFieldType) typeOfFieldWithKey:(NSString *)key {
    NSDictionary *field = [self fieldForKey:key];
    return [self typeForString:field[@"type"]];
}

- (BOOL) fieldWithKey:(NSString *)key isOfType:(SPRemoteFieldType)type {
    return [self typeOfFieldWithKey:key] == type;
}

- (NSString *) keyForFieldWithIndex:(NSInteger) index {
    return [self orderedKeys][index];
}


- (NSArray *) orderedKeys {
    return self.remote[@"ordered_keys"];
}

- (SPRemoteFieldType) typeForString:(NSString *)string {
    
    NSDictionary *stringTypeDict = @{
                                     @"text": @(SPRemoteFieldTypeText),
                                     @"number": @(SPRemoteFieldTypeNumber),
                                     @"boolean": @(SPRemoteFieldTypeBoolean),
                                     @"multiple": @(SPRemoteFieldTypeMultiple),
                                     @"action": @(SPRemoteFieldTypeAction)
                                     };
    NSNumber *value = [stringTypeDict objectForKey:string];
    
    if (value) {
        return [value integerValue];
    } else {
        return SPRemoteFieldTypeUnknown;
    }
    
}

@end
