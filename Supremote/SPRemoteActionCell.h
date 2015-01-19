//
//  SPRemoteActionCell.h
//  Supremote
//
//  Created by Lambda Omega on 1/19/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPRemoteCell.h"

typedef NS_ENUM(NSInteger, SPRemoteActionClass) {
    SPRemoteActionClassDefault,
    SPRemoteActionClassPrimary,
    SPRemoteActionClassSuccess,
    SPRemoteActionClassInfo,
    SPRemoteActionClassWarning,
    SPRemoteActionClassDanger
};

@interface SPRemoteActionCell : SPRemoteCell

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL *action;

@property (nonatomic, assign) SPRemoteActionClass actionClass;

@end
