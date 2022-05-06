//
//  FATClientHelper.h
//  Uniplugins-MopSdk
//
//  Created by 杨彬 on 2022/4/30.
//  Copyright © 2022 DCloud. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <FinApplet/FinApplet.h>
#import "DCUniModule.h"
#import "MopSdkModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface FATClientHelper : NSObject<FATAppletDelegate>

+ (instancetype)shareInstance;

@property (nonatomic, strong) MopSdkModule *mopSdkModule;

@property (nonatomic, strong) UniModuleKeepAliveCallback onInitComplete;
@property (nonatomic, strong) UniModuleKeepAliveCallback onFailure;
@property (nonatomic, strong) UniModuleKeepAliveCallback onCreate;
@property (nonatomic, strong) UniModuleKeepAliveCallback onStart;
@property (nonatomic, strong) UniModuleKeepAliveCallback onResume;
@property (nonatomic, strong) UniModuleKeepAliveCallback onPause;
@property (nonatomic, strong) UniModuleKeepAliveCallback onStop;
@property (nonatomic, strong) UniModuleKeepAliveCallback onDestroy;

@property (nonatomic, strong) UniModuleKeepAliveCallback onCloseButtonClicked;
@property (nonatomic, strong) UniModuleKeepAliveCallback onChooseAvatar;
@property (nonatomic, strong) UniModuleKeepAliveCallback onGetPhoneNumber;

@property (nonatomic, strong) NSArray<id<FATAppletMenuProtocol>> *registeredMoreMenuItems;
@property (nonatomic, strong) UniModuleKeepAliveCallback onRegisteredMoreMenuItemClicked;

@property (nonatomic, strong) NSDictionary *grayAppletVersionConfigs;
@property (nonatomic, strong) NSDictionary *userInfo;

@end

NS_ASSUME_NONNULL_END
