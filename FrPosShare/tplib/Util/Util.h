//
//  Util.h
//  FrPosShare
//
//  Created by liuhanchong on 16/8/21.
//  Copyright © 2016年 liuhanchong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CONFIG [Util componPath:NSHomeDirectory() name:@"config"]
#define SYSCONFIGFILE @"sys.plist"
#define USERHEADIMAGE @"imageHead.jpg"
#define USERHEADSIZE {100, 100}

@interface Util : NSObject

+ (void)showAlert:(NSString *)message view:(UIViewController *)view;
+ (BOOL)isExistPList:(NSString *)name;
+ (BOOL)createPList:(NSString *)name;
+ (BOOL)writePList:(NSMutableDictionary *)usersDic name:(NSString *)name;
+ (NSMutableDictionary *)readPList:(NSString *)name;
+ (NSString *)componPath:(NSString *)path name:(NSString *)name;
+ (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;
+ (UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;

@end
