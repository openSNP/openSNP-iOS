//
//  OSTableViewCell.h
//  openSNP
//
//  Created by gdyer on 03/07/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateTag;
@property (weak, nonatomic) IBOutlet UILabel *articleBody;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end
