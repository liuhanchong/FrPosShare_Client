//
//  Sign.h
//  FrPosShare
//
//  Created by liuhanchong on 16/8/22.
//  Copyright © 2016年 liuhanchong. All rights reserved.
//

#import "ModelObject.h"
#import "Util.h"

@interface Sign : ModelObject

- (NSUInteger)sign:(NSString *)nickName telPhone:(NSString *)telPhone imageHead:(UIImageView *)imageHead;
- (BOOL)skipToMainView;
- (NSString *)getMessage:(NSUInteger)ret;

@end
