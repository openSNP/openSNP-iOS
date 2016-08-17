//
//  OSActionTableViewCell.h
//  openSNP
//
//  Created by gdyer on 7/19/16.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <UIKit/UIKit.h>

// OSInfoTableViewCells have an action when tapped; they convey little information
// Each instance has a completion block, making it easy to create new actions
@interface OSActionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *actionDescriptionLabel;
@property (assign) void (^action)(void);

@end
