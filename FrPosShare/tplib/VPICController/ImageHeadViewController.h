//
//  ImageHeadViewController.h
//  FrPosShare
//
//  Created by liuhanchong on 16/8/21.
//  Copyright © 2016年 liuhanchong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface ImageHeadViewController : NSObject

@property (weak, nonatomic) ViewController *viewController;
@property (strong, nonatomic) IBOutlet UIImageView *portraitImageView;

- (instancetype) initWithParentController:(ViewController *)viewController;
- (void)loadPortrait;

@end
