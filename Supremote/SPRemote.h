//
//  SPRemote.h
//  Supremote
//
//  Created by Lambda Omega on 1/20/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SPRemoteFieldType) {
    SPRemoteFieldTypeUnknown = -1,
    SPRemoteFieldTypeText,
    SPRemoteFieldTypeNumber,
    SPRemoteFieldTypeBoolean,
    SPRemoteFieldTypeMultiple,
    SPRemoteFieldTypeAction
};

@interface SPRemote : NSObject

@property (nonatomic, readonly, strong) NSMutableDictionary *values;

+ (instancetype) remoteFromDictionary:(NSDictionary *)dictionary;

- (id) getCurrentValueForKey:(NSString *)key;
- (void) setCurrentValue:(id)value forKey:(NSString *)key;

- (void) commit;
- (void) rollback;

- (NSString *) name;
- (NSNumber *) remoteId;
- (NSInteger) fieldCount;
- (NSArray *) orderedKeys;
- (NSArray *) fieldsets;
- (NSDictionary *) fieldForKey:(NSString *)key;
- (NSString *) keyForFieldWithIndex:(NSInteger) index;
- (BOOL) fieldWithKey:(NSString *)key isOfType:(SPRemoteFieldType)type;
- (SPRemoteFieldType) typeOfFieldWithKey:(NSString *)key;

@end
