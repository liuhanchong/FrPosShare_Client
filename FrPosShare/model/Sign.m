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
            return 5;
        }
    }
    
    //保存用户信息
    NSMutableDictionary *usersDic = [[NSMutableDictionary alloc] init];
    [usersDic setObject:nickName forKey:@"nickName"];
    [usersDic setObject:telPhone forKey:@"telPhone"];
    [usersDic setObject:USERHEADIMAGE forKey:@"imageHead"];
    if (![Util writePList:usersDic name:plistName]){
        return 5;
    }
    
    //本地保存用户头像
    NSString *imagePath = [Util componPath:CONFIG name:USERHEADIMAGE];
    NSLog(@"%@", imagePath);
    if (![UIImageJPEGRepresentation(comImageHead, 0.0) writeToFile:imagePath atomically:YES]){
        return 5;
    }
    
    //将注册信息上传到服务器
    return [self signToServer:nickName telPhone:telPhone imageHead:[UIImage imageNamed:imagePath]];
}

- (NSUInteger)signToServer:(NSString *)nickName telPhone:(NSString *)telPhone imageHead:(UIImage *)imageHead
{
   //设置请求路径
    NSString *http = [NSString stringWithFormat:@"%@%@", [Util getURLString:@"http"], [Util getURLString:@"login"]];
    NSURL *url = [NSURL URLWithString:http];
    
    //创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];//默认为get请求
    request.timeoutInterval = 5.0;//设置请求超时为5秒
    request.HTTPMethod = @"POST";//设置请求方法
    
    // 2.设置请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // 3.设置请求体
    NSDictionary *json = @{@"nickName" : nickName,
                           @"telPhone" : telPhone};
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    
    //发送请求
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        //没有错误
        if (error == nil) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (json == nil)
            {
                self.signState = 2;
                NSLog(@"signToServer->JSONObjectWithData failed");
                return;
            }
            
            self.signState = [[json objectForKey:@"state"] intValue];
        }
        else{
            self.signState = 3;
            NSLog(@"Sign->signToServer failed, %@", [error localizedDescription]);
        }
    }] resume];
    
    return 0;
}

// 1.接收到服务器的响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    // 允许处理服务器的响应，才会继续接收服务器返回的数据
    completionHandler(NSURLSessionResponseAllow);
}

// 2.接收到服务器的数据（可能调用多次）
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // 处理每次接收的数据
}

// 3.请求成功或者失败（如果失败，error有值）
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // 请求完成,成功或者失败的处理
    NSLog(@"123");
}

- (BOOL)skipToMainView
{
    NSMutableDictionary *usersDic = [Util readPList:SYSCONFIGFILE];
    if (usersDic){
        if ([[usersDic valueForKey:@"telPhone"] length] > 0 &&
            [[usersDic valueForKey:@"nickName"] length] > 0 &&
            [[usersDic valueForKey:@"imageHead"] length] > 0){
        }
        //获取到用户信息
    }
    
    return NO;
}

- (NSString *)getMessage:(NSUInteger)ret
{
    NSString *message = nil;
    if (ret == 1){
        message = @"登陆成功!";
    }
    else if (ret == 2){//注册失败
        message = @"注册失败!";
    }
    else if (ret == 3){//网络存在问题
        message = @"无法连接到服务器,请稍后再试!";
    }
    else if (ret == 4){//此用户已注册
        message = [NSString stringWithFormat:@"此用户已经注册,请登录!"];
    }
    else if (ret == 5){//注册信息写入配置文件失败
        message = [NSString stringWithFormat:@"注册信息写入配置文件失败!"];
    }
    else if (ret == 6){//业务忙
        message = [NSString stringWithFormat:@"注册当前服务器忙，请稍后再试!"];
    }
    else{
        message = @"未知错误!";
    }
    
    return message;
}

@end
