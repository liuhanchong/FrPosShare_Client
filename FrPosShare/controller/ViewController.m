//
//  ViewController.m
//  FrPosShare
//
//  Created by liuhanchong on 16/8/19.
//  Copyright © 2016年 liuhanchong. All rights reserved.
//

#import "ViewController.h"
#import "ImageHeadViewController.h"
#import "Util.h"
#import "Sign.h"

@interface ViewController () <UITextFieldDelegate>

@property (strong, nonatomic) ImageHeadViewController *imageHead;
@property (strong, nonatomic) IBOutlet UITextField *textNickName;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activeIndWait;
@property (strong, nonatomic) IBOutlet UIButton *buttonSign;
@property (nonatomic) BOOL signing;
@property (strong, nonatomic) IBOutlet UITextField *textTelNo;
@property (strong, nonatomic) IBOutlet UILabel *labelTip;
@property (strong, nonatomic) Sign *userSign;//用户注册

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化登录模块
    self.userSign = [[Sign alloc] init];
    
    //加载头像控件
    self.imageHead = [[ImageHeadViewController alloc] initWithParentController:self];
    [self.imageHead loadPortrait];
    
    //设置昵称文本框
    [self.textNickName addTarget:self action:@selector(limitNickNameLength:) forControlEvents:UIControlEventEditingChanged];
    self.textNickName.returnKeyType =UIReturnKeyNext;
    self.textNickName.delegate = self;
    [self nickNameTip:YES];

    //设置手机号文本框
    [self.textTelNo addTarget:self action:@selector(limitTelNoLength:) forControlEvents:UIControlEventEditingChanged];
    self.textTelNo.keyboardType = UIKeyboardTypeNumberPad;
    self.textTelNo.returnKeyType =UIReturnKeyGo;
    self.textTelNo.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.textTelNo.delegate = self;
    [self telNoTip:YES];
    
    //设置其它
    [self.activeIndWait setHidden:YES];
    [self buttonSignEnable];
    [self.buttonSign addTarget:self action:@selector(clickButtonSign:) forControlEvents:UIControlEventTouchDown];
    
    //如果符合条件 自动跳转到主视图
    [self.userSign skipToMainView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark UITextField Delegate method
- (BOOL)textFieldShouldBeginEditing:(UITextField*) textField
{
    textField.clearButtonMode = UITextFieldViewModeAlways;
    
    if (textField == self.textNickName){
        if ([textField.text isEqualToString:@"至少6个字符"]){
            textField.text = @"";
        }
    }
    else if (textField == self.textTelNo){
        if ([textField.text isEqualToString:@"必须为11位数字"]){
            textField.text = @"";
        }
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *) textField
{
}

- (BOOL)textFieldShouldEndEditing:(UITextField *) textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *) textField
{
    textField.clearButtonMode = UITextFieldViewModeNever;
    
    if (textField.text.length < 1){
        if (textField == self.textNickName){
            [self nickNameTip:YES];
        }
        else if (textField == self.textTelNo){
            [self telNoTip:YES];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *) textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)nickNameTip:(BOOL)tip
{
    if (tip){
        self.textNickName.text = @"至少6个字符";
        self.textNickName.textColor = [UIColor lightGrayColor];
    }
    else{
        self.textNickName.textColor = [UIColor darkTextColor];
    }
}

- (void)telNoTip:(BOOL)tip
{
    if (tip){
        self.textTelNo.text = @"必须为11位数字";
        self.textTelNo.textColor = [UIColor lightGrayColor];
    }
    else{
        self.textTelNo.textColor = [UIColor darkTextColor];
    }
}

- (void)limitNickNameLength:(id)sender
{
    int limitLen = 14;
    NSString *text = self.textNickName.text;
    if ([text length] > limitLen){
        text = [text substringToIndex:limitLen];
    }
    self.textNickName.text = text;
    
    [self buttonSignEnable];
}

- (void)limitTelNoLength:(id)sender
{
    int limitLen = 11;
    NSString *text = self.textTelNo.text;
    if ([text length] > limitLen){
        text = [text substringToIndex:limitLen];
    }
    
    //判断是否出现非数字以外的字符
    if ([text length] > 0 &&
        ([text characterAtIndex:[text length] - 1] < '0' || [text characterAtIndex:[text length] - 1] > '9')){
        text = [text substringToIndex:[text length] - 1];
    }
    self.textTelNo.text = text;
    
    [self buttonSignEnable];
}

- (void)setButtonSignContent
{
    if (self.signing){
        [self.buttonSign setTitle:@"" forState:UIControlStateDisabled];
    }
    else{
        [self.buttonSign setTitle:@"注册" forState:UIControlStateNormal];
        [self.buttonSign setTitle:@"注册" forState:UIControlStateDisabled];
    }
    
    [self buttonSignEnable];
}

- (void)buttonSignEnable
{
    if (self.signing){
        [self setButtonSignState:NO];
        return;
    }
    
    if ([self.textNickName.text length] < 6){
        [self setButtonSignState:NO];
        return;
    }
    
    if ([self.textTelNo.text length] != 11){
        [self setButtonSignState:NO];
        return;
    }
    
    [self setButtonSignState:YES];
}

- (void)setButtonSignState:(BOOL)enable
{
    if (enable){
        [self.buttonSign setEnabled:YES];
        [self.buttonSign setBackgroundColor:[UIColor colorWithRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:0.87]];
    }
    else{
        [self.buttonSign setEnabled:NO];
        [self.buttonSign setBackgroundColor:[UIColor lightGrayColor]];
    }
}

- (void)clickButtonSign:(id)sender
{
    self.signing = YES;
    [self setButtonSignContent];
    [self.activeIndWait setHidden:NO];
    [self.activeIndWait startAnimating];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //注册
        NSString *nickName = self.textNickName.text;
        NSString *telPhone = self.textTelNo.text;
        UIImageView *imageHead = self.imageHead.portraitImageView;
        NSUInteger ret = [self.userSign sign:nickName telPhone:telPhone imageHead:imageHead];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //注册成功
            if (ret == 0){
               if ([self.userSign skipToMainView])
               {
                   return;
               }
            }
            
            //失败后显示消息提示
            [Util showAlert:[self.userSign getMessage:ret] view:self];
            
            self.signing = NO;
            [self.activeIndWait stopAnimating];
            [self.activeIndWait setHidden:YES];
            [self setButtonSignContent];
        });
    });
}


@end
