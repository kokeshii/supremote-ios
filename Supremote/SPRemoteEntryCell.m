//
//  SPRemoteEntryCell.m
//  Supremote
//
//  Created by Lambda Omega on 1/21/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPRemoteEntryCell.h"

@implementation SPRemoteEntryCell

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.remoteImageView.layer.cornerRadius = 20.9f;
    self.remoteImageView.clipsToBounds = YES;
    
}

@end
