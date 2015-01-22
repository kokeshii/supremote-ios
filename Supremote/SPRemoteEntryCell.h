//
//  SPRemoteEntryCell.h
//  Supremote
//
//  Created by Lambda Omega on 1/21/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPRemoteEntryCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *remoteNameLabel, *developerNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *remoteImageView;

@end
