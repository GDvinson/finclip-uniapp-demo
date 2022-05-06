//
//  FATClientHelper.m
//  Uniplugins-MopSdk
//
//  Created by 杨彬 on 2022/4/30.
//  Copyright © 2022 DCloud. All rights reserved.
//

#import "FATClientHelper.h"
#import <Foundation/Foundation.h>
#import <FinApplet/FinApplet.h>

@implementation FATClientHelper

static FATClientHelper *instance = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
       dispatch_once(&onceToken, ^{
           instance = [[FATClientHelper alloc] init];
       });
       return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (id)copy {
    return instance;
}

#pragma mark - FATAppletDelegate

//- (void)contactWithAppletInfo:(FATAppletInfo *)appletInfo sessionFrom:(NSString *)sessionFrom sendMessageTitle:(NSString *)sendMessageTitle sendMessagePath:(NSString *)sendMessagePath sendMessageImg:(NSString *)sendMessageImg showMessageCard:(BOOL)showMessageCard
//{
//
//}

//- (void)applet:(FATAppletInfo *)appletInfo didClickMoreBtnAtPath:(NSString *)path
//{
//
//}


//- (void)launchAppWithAppletInfo:(FATAppletInfo *)appletInfo appParameter:(NSString *)appParameter bindError:(void (^)(NSDictionary *result))bindError bindLaunchApp:(void (^)(NSDictionary *result))bindLaunchApp
//{
//
//}
//
//- (void)feedbackWithAppletInfo:(FATAppletInfo *)appletInfo
//{
//
//}

//- (void)forwardAppletWithInfo:(NSDictionary *)contentInfo completion:(void (^)(FATExtensionCode, NSDictionary *))completion
//{
//    NSLog(@"小程序信息:%@", contentInfo);
//
//    // 1.如果你需要将小程序转发到自己app的聊天室，那么就根据contentInfo封装成自己IM消息，然后发送。
//
//    // 2.如果你需要将小程序转发到自己app的朋友圈，那么就根据contentInfo，组装信息发送给后台。
//}

- (NSDictionary *)grayExtensionWithAppletId:(NSString *)appletId
{
    return self.grayAppletVersionConfigs;
}

- (NSDictionary *)getUserInfoWithAppletInfo:(FATAppletInfo *)appletInfo
{
    return self.userInfo;
}

- (void)getPhoneNumberWithAppletInfo:(FATAppletInfo *)appletInfo bindGetPhoneNumber:(void (^)(NSDictionary *result))bindGetPhoneNumber
{
    if (self.onGetPhoneNumber) {
        [[self mopSdkModule] addExtenssionApiCallback:^(FATExtensionCode code, NSDictionary *result) {
            bindGetPhoneNumber(result);
        }];
        self.onGetPhoneNumber(nil,YES);
    }
}

- (void)chooseAvatarWithAppletInfo:(FATAppletInfo *)appletInfo bindChooseAvatar:(void (^)(NSDictionary *result))bindChooseAvatar
{
    if (self.onChooseAvatar) {
        [[self mopSdkModule] addExtenssionApiCallback:^(FATExtensionCode code, NSDictionary *result) {
            bindChooseAvatar(result);
        }];
        self.onChooseAvatar(nil,YES);
    }
}

- (void)applet:(NSString *)appletId didOpenCompletion:(NSError *)error
{
    if (self.onCloseButtonClicked) {
        self.onCloseButtonClicked(appletId,YES);
    }
    if (self.onStart) {
        self.onStart(@{@"appid":appletId},YES);
    }
}

- (void)applet:(NSString *)appletId didCloseCompletion:(NSError *)error
{
    if (self.onCloseButtonClicked) {
        self.onCloseButtonClicked(appletId,YES);
    }
    if (self.onStop) {
        self.onStop(@{@"appid":appletId},YES);
    }
}

- (void)applet:(NSString *)appletId initCompletion:(NSError *)error
{
    if (self.onInitComplete) {
        self.onInitComplete(@{@"appid":appletId},YES);
    }
}

- (void)applet:(NSString *)appletId didActive:(NSError *)error
{
    if (self.onResume) {
        self.onResume(@{@"appid":appletId},YES);
    }
}

- (void)applet:(NSString *)appletId resignActive:(NSError *)error
{
    if (self.onPause) {
        self.onPause(@{@"appid":appletId},YES);
    }
}

- (void)applet:(NSString *)appletId didFail:(NSError *)error
{
    if (self.onFailure) {
        self.onFailure(@{@"appid":appletId,@"code":[NSString stringWithFormat: @"%ld", error.code] },YES);
    }
}

- (void)applet:(NSString *)appletId dealloc:(NSError *)error
{
    if (self.onDestroy) {
        self.onDestroy(@{@"appid":appletId },YES);
    }
}


- (NSArray<id<FATAppletMenuProtocol>> *)customMenusInApplet:(FATAppletInfo *)appletInfo atPath:(NSString *)path
{
    return self.registeredMoreMenuItems;
}

- (void)clickCustomItemMenuWithInfo:(NSDictionary *)contentInfo inApplet:(FATAppletInfo *)appletInfo completion:(void (^)(FATExtensionCode code, NSDictionary *result))completion
{
    if (self.onRegisteredMoreMenuItemClicked) {
        [[self mopSdkModule] addExtenssionApiCallback:completion];
        
        self.onRegisteredMoreMenuItemClicked(@{@"appId": [appletInfo appId],
                                               @"path": contentInfo[@"path"],
                                               @"menuItemId": contentInfo[@"menuId"],
                                               @"appInfo": contentInfo
                                             }, YES);
    }
}
@end

