//
//  OSSystemMessageViewer.m
//  openSNP
//
//  Created by gdyer on 09/08/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSSystemMessageViewer.h"

@implementation OSSystemMessageViewer

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"system message"];
    [self.message setText:_messageText];
    [self.message setFont:[UIFont fontWithName:@"Avenir Book" size:15.0f]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end