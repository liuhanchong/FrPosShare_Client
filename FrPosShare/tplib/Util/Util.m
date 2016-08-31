//
//  Util.m
//  FrPosShare
//
//  Created by liuhanchong on 16/8/21.
//  Copyright © 2016年 liuhanchong. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (void)showAlert:(NSString *)message view:(UIViewController *)view
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle: UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [view presentViewController:alert animated:true completion:nil];
}

+ (NSString *)componPath:(NSString *)path name:(NSString *)name
{
    return [path stringByAppendingPathComponent:name];
}

+ (BOOL)isExistPList:(NSString *)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:CONFIG isDirectory:&isDir];
    //目录不存在
    if (!isDirExist){
        if(![fileManager createDirectoryAtPath:CONFIG withIntermediateDirectories:YES attributes:nil error:nil]){
            NSLog(@"失败");
            return NO;
        }
    }
    
    //获取完整路径
    NSString *plistPath = [self componPath:CONFIG name:name];
    
    return [fileManager fileExistsAtPath:plistPath];
}

+ (BOOL)createPList:(NSString *)name
{
    NSString *plistPath = [self componPath:CONFIG name:name];
    
    NSData *contentData = [@"" dataUsingEncoding:NSASCIIStringEncoding];
    return [contentData writeToFile:plistPath atomically:YES];
}

+ (BOOL)writePList:(NSMutableDictionary *)usersDic name:(NSString *)name
{
    NSString *plistPath = [self componPath:CONFIG name:name];
    
    NSMutableDictionary *usersDicFPList = [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
    NSEnumerator *dicKeyFormPList = [usersDicFPList keyEnumerator];
    NSEnumerator *dicKey = [usersDic keyEnumerator];
    
    NSLog(@"Get file path: %@", plistPath);
    
    BOOL find = NO;
    for (NSString *keyFromPList in dicKeyFormPList){
        find = NO;
        dicKey = [usersDic keyEnumerator];
        for (NSString *key in dicKey){
            if ([keyFromPList isEqualToString:key]){
                find = YES;
                break;
            }
        }
        if (!find){
            [usersDic setObject:[usersDicFPList valueForKey:keyFromPList] forKey:keyFromPList];
        }
    }

   return [usersDic writeToFile:plistPath atomically:YES];
}

+ (NSMutableDictionary *)readPList:(NSString *)name
{
    NSString *plistPath = [self componPath:CONFIG name:name];

    return [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
}

+ (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = (targetWidth / width) * height;
    
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0,0,targetWidth,  targetHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

@end
