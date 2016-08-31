//
//  Sign.m
//  FrPosShare
//
//  Created by liuhanchong on 16/8/22.
//  Copyright © 2016年 liuhanchong. All rights reserved.
//

#import "Sign.h"

@interface Sign()

@end

@implementation Sign

- (NSUInteger)sign:(NSString *)nickName telPhone:(NSString *)telPhone imageHead:(UIImageView *)imageHead
{
    //图像压缩
    CGSize imageSize = USERHEADSIZE;
    UIImage *comImageHead = [Util imageCompressForSize:imageHead.image targetSize:imageSize];

    //将注册信息写入文件
    NSString *plistName = SYSCONFIGFILE;
    if (![Util isExistPList:plistName])
    {
        if (![Util createPList:plistName]){
            return 4;
        }
    }
    
    //保存用户信息
    NSMutableDictionary *usersDic = [[NSMutableDictionary alloc] init];
    [usersDic setObject:nickName forKey:@"nickName"];
    [usersDic setObject:telPhone forKey:@"telPhone"];
    [usersDic setObject:USERHEADIMAGE forKey:@"imageHead"];
    if (![Util writePList:usersDic name:plistName]){
        return 4;
    }
    
    //本地保存用户头像
    NSString *imagePath = [Util componPath:CONFIG name:USERHEADIMAGE];
    NSLog(@"%@", imagePath);
    if (![UIImageJPEGRepresentation(comImageHead, 0.0) writeToFile:imagePath atomically:YES]){
        return 4;
    }
    
    //将注册信息上传到服务器
    return [self signToServer:nickName telPhone:telPhone imageHead:[UIImage imageNamed:imagePath]];
}

- (NSUInteger)signToServer:(NSString *)nickName telPhone:(NSString *)telPhone imageHead:(UIImage *)imageHead
{
    return 0;
}

- (BOOL)skipToMainView
{
    NSMutableDictionary *usersDic = [Util readPList:SYSCONFIGFILE];
    if (usersDic){
        if ([[usersDic valueForKey:@"telPhone"] length] > 0 &&
            [[usersDic valueForKey:@"nickName"] length] > 0 &&
            [[usersDic valueForKey:@"imageHead"] length] > 0){
        }
    }
    
    return NO;
}

- (NSString *)getMessage:(NSUInteger)ret
{
    NSString *message = nil;
    if (ret == 0){
        message = @"登陆成功!";
    }
    else if (ret == 1){//注册失败
        message = @"注册失败!";
    }
    else if (ret == 2){//网络存在问题
        message = @"无法连接到服务器,请稍后再试!";
    }
    else if (ret == 3){//此用户已注册
        message = [NSString stringWithFormat:@"此用户已经注册,请登录!"];
    }
    else if (ret == 4){//注册信息写入配置文件失败
        message = [NSString stringWithFormat:@"注册信息写入配置文件失败!"];
    }
    else{
        message = @"未知错误!";
    }
    
    return message;
}

@end
