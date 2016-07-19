//
//  OSActionTableViewCell.h
//  openSNP
//
//  Created by gdyer on 7/19/16.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <UIKit/UIKit.h>

// OSInfoTableViewCells have an action when tapped; they convey little information
// Each action must be handled individually by the controller, thus they are rare.
@interface OSActionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *actionDescriptionLabel;
@property (assign) NSInteger actionId;

@end
