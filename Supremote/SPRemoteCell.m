//
//  SPRemoteCell.m
//  Supremote
//
//  Created by Lambda Omega on 1/17/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPRemoteCell.h"
#import <Classy.h>

@implementation SPRemoteCell

- (void) awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.cas_styleClass = @"remoteFieldName";
}


@end
