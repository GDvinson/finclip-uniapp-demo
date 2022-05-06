//
//  TestModule.m
//  DCTestUniPlugin
//
//  Created by XHY on 2020/4/22.
//  Copyright © 2020 DCloud. All rights reserved.
//
#import <FinApplet/FinApplet.h>

#import "MopSdkModule.h"
#import "FATClientHelper.h"

@implementation MopSdkModule

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;

    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}
- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    }
    else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}
-(UIColor*)colorWithARGB:(NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
        
    // String should be 6 or 8 characters
    if ([cString length] < 8)
    {
        return [UIColor clearColor];
    }
        
    // 判断前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 8)
        return [UIColor clearColor];


    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //A、 R、G、B
    unsigned int a, r, g, b;
    NSString *aString = [cString substringWithRange:range];
    range.location = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 4;
    NSString *gString = [cString substringWithRange:range];
    range.location = 6;
    NSString *bString = [cString substringWithRange:range];
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed: r/255.0f
                           green: g/255.0f
                           blue: b/255.0f
                           alpha: a/255.0f];
}

- (NSString *) uuidString{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}


// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(initialize:success:fail:))

/// 初始化（注：异步方法会在主线程（UI线程）执行）
/// @param config js 端调用方法时传递的参数
/// @param success 回调方法，回传参数给 js 端
/// @param fail 回调方法，回传参数给 js 端
- (void)initialize:(NSDictionary *)config success:(UniModuleKeepAliveCallback)success fail:(UniModuleKeepAliveCallback)fail {
    NSLog(@"%@",config);
    @try {
        NSMutableArray *storeArrayM = config[@"finStoreConfigs"];
        if (!storeArrayM || storeArrayM.count == 0) {
            storeArrayM = [NSMutableArray array];
            FATStoreConfig *storeConfig = [[FATStoreConfig alloc] init];
            storeConfig.sdkKey = config[@"sdkKey"];
            storeConfig.sdkSecret = config[@"sdkSecret"];
            storeConfig.apiServer = !config[@"apiServer"] ? config[@"apmServer"] : config[@"apiServer"];
            //storeConfig.apiPrefix = config[@"apiPrefix"];
            storeConfig.apmServer = config[@"apmServer"];
            if ([@"SM" isEqualToString:config[@"cryptType"]]) {
                storeConfig.cryptType = FATApiCryptTypeSM;
            } else {
                storeConfig.cryptType = FATApiCryptTypeMD5;
            }
            if (!config[@"cryptType"])
                storeConfig.encryptServerData = config[@"encryptServerData"];
            if (!config[@"sdkFingerprint"])
                storeConfig.fingerprint = config[@"sdkFingerprint"];
            [storeArrayM addObject:storeConfig];
        }
        
        FATConfig *fatConfig = [FATConfig configWithStoreConfigs:storeArrayM];
        fatConfig.apiServer = !config[@"apiServer"] ? config[@"apmServer"] : config[@"apiServer"];
        fatConfig.apmServer =  config[@"apmServer"];
        if (config[@"sdkFingerprint"])
            fatConfig.fingerprint  = config[@"sdkFingerprint"];
        if (config[@"encryptServerData"])
            fatConfig.encryptServerData = config[@"encryptServerData"];
        if (config[@"apmExtendInfo"])
            fatConfig.apmExtension = config[@"apmExtendInfo"];
        if (config[@"enableAppletDebug"])
            fatConfig.enableAppletDebug = config[@"enableAppletDebug"];
        if (config[@"appletAutoAuthorize"])
            fatConfig.appletAutoAuthorize = config[@"appletAutoAuthorize"];
        if (config[@"appletIntervalUpdateLimit"])
            fatConfig.appletIntervalUpdateLimit = [config[@"appletIntervalUpdateLimit"] intValue];
        if (config[@"disablePermission"])
            fatConfig.disableAuthorize = config[@"disablePermission"];
        if (config[@"disableGetSuperviseInfo"])
            fatConfig.disableGetSuperviseInfo = config[@"disableGetSuperviseInfo"];
        if (config[@"enableApmDataCompression"])
            fatConfig.enableApmDataCompression = config[@"enableApmDataCompression"];
        if (config[@"userId"])
            fatConfig.currentUserId = config[@"userId"];
        
        if (config[@"uiConfig"]) {
            FATUIConfig *uiConfig = [[FATUIConfig alloc] init];
            //是否隐藏小程序加载界面的关闭按钮
            if (config[@"uiConfig"][@"hideTransitionCloseButton"])
                uiConfig.hideTransitionCloseButton = ([config[@"uiConfig"][@"hideTransitionCloseButton"] intValue] == 1 ? YES : NO);
            else uiConfig.hideTransitionCloseButton = false;
            //屏蔽更多菜单中的“转发”按钮
            if (config[@"uiConfig"][@"hideForwardMenu"])
                uiConfig.hideForwardMenu = [config[@"uiConfig"][@"hideForwardMenu"] intValue] == 1 ? YES : NO;
            else uiConfig.hideForwardMenu = NO;
            //屏蔽更多菜单中的“设置”按钮
            if (config[@"uiConfig"][@"hideSettingMenu"])
                uiConfig.hideSettingMenu = [config[@"uiConfig"][@"hideSettingMenu"] intValue] ==  1 ? YES : NO;
            else uiConfig.hideSettingMenu = NO;
            //屏蔽更多菜单中的“返回首页”按钮
            if (config[@"uiConfig"][@"hideBackToHome"])
                uiConfig.hideBackToHome = [config[@"uiConfig"][@"hideBackToHome"] intValue] ==  1 ? YES : NO;
            else uiConfig.hideBackToHome = NO;
            //屏蔽更多菜单中的“反馈与投诉”按钮
            if (config[@"uiConfig"][@"hideFeedbackMenu"])
                uiConfig.hideFeedbackMenu = [config[@"uiConfig"][@"hideFeedbackMenu"] intValue] ==  1 ? YES : NO;
            else uiConfig.hideFeedbackMenu = NO;
            //SDK中“小程序”文案替换为任意其它名称
            if (config[@"uiConfig"][@"appletText"])
                uiConfig.appletText = config[@"uiConfig"][@"appletText"];
            //web-view的user-agent
            if (config[@"customWebViewUserAgent"])
                uiConfig.appendingCustomUserAgent = config[@"customWebViewUserAgent"];
            
            //胶囊按钮配置
            uiConfig.capsuleConfig = [[FATCapsuleConfig alloc] init];
            if (config[@"uiConfig"][@"capsuleConfig"]){
                //右上角胶囊视图的宽度，默认值为88
                if (config[@"uiConfig"][@"capsuleConfig"][@"capsuleWidth"])
                    uiConfig.capsuleConfig.capsuleWidth = [config[@"uiConfig"][@"capsuleConfig"][@"capsuleWidth"] floatValue];
                //右上角胶囊视图的高度，默认值为32
                if (config[@"uiConfig"][@"capsuleConfig"][@"capsuleHeight"])
                    uiConfig.capsuleConfig.capsuleHeight = [config[@"uiConfig"][@"capsuleConfig"][@"capsuleHeight"] floatValue];
                //右上角胶囊视图的右边距
                if (config[@"uiConfig"][@"capsuleConfig"][@"capsuleRightMargin"])
                    uiConfig.capsuleConfig.capsuleRightMargin = [config[@"uiConfig"][@"capsuleConfig"][@"capsuleRightMargin"] floatValue];
                //右上角胶囊视图的圆角半径，默认值为5
                if (config[@"uiConfig"][@"capsuleConfig"][@"capsuleCornerRadius"])
                    uiConfig.capsuleConfig.capsuleCornerRadius = [config[@"uiConfig"][@"capsuleConfig"][@"capsuleCornerRadius"] floatValue];
                //右上角胶囊视图的边框宽度，默认值为0.8
                if (config[@"uiConfig"][@"capsuleConfig"][@"capsuleBorderWidth"])
                    uiConfig.capsuleConfig.capsuleBorderWidth = [config[@"uiConfig"][@"capsuleConfig"][@"capsuleBorderWidth"] floatValue];
//                //胶囊背景颜色浅色
                if (config[@"uiConfig"][@"capsuleConfig"][@"capsuleBgLightColor"])
                    uiConfig.capsuleConfig.capsuleBgLightColor =  [self colorWithARGB:config[@"uiConfig"][@"capsuleConfig"][@"capsuleBgLightColor"]];
                //胶囊背景颜色深色
                if (config[@"uiConfig"][@"capsuleConfig"][@"capsuleBgDarkColor"])
                    uiConfig.capsuleConfig.capsuleBgDarkColor = [self colorWithARGB:config[@"uiConfig"][@"capsuleConfig"][@"capsuleBgDarkColor"]];
                //右上角胶囊视图的边框浅色颜色
                if (config[@"uiConfig"][@"capsuleConfig"][@"capsuleBorderLightColor"])
                    uiConfig.capsuleConfig.capsuleBorderLightColor = [self colorWithARGB:config[@"uiConfig"][@"capsuleConfig"][@"capsuleBorderLightColor"]];
                //右上角胶囊视图的边框深色颜色
                if (config[@"uiConfig"][@"capsuleConfig"][@"capsuleBorderDarkColor"])
                    uiConfig.capsuleConfig.capsuleBorderDarkColor = [self colorWithARGB:config[@"uiConfig"][@"capsuleConfig"][@"capsuleBorderDarkColor"]];
                // 胶囊分割线浅色颜色
                if (config[@"uiConfig"][@"capsuleConfig"][@"capsuleDividerLightColor"])
                    uiConfig.capsuleConfig.capsuleDividerLightColor = [self colorWithARGB:config[@"uiConfig"][@"capsuleConfig"][@"capsuleDividerLightColor"]];
                // 胶囊分割线深色颜色
                if (config[@"uiConfig"][@"capsuleConfig"][@"capsuleDividerDarkColor"])
                    uiConfig.capsuleConfig.capsuleDividerDarkColor = [self colorWithARGB:config[@"uiConfig"][@"capsuleConfig"][@"capsuleDividerDarkColor"]];
                // 胶囊里的更多按钮的宽度，高度与宽度相等
                if (config[@"uiConfig"][@"capsuleConfig"][@"moreBtnWidth"])
                    uiConfig.capsuleConfig.moreBtnWidth = [config[@"uiConfig"][@"capsuleConfig"][@"moreBtnWidth"] floatValue] - 12;
                // 胶囊里的更多按钮的左边距
                if (config[@"uiConfig"][@"capsuleConfig"][@"moreBtnLeftMargin"])
                    uiConfig.capsuleConfig.moreBtnLeftMargin = [config[@"uiConfig"][@"capsuleConfig"][@"moreBtnLeftMargin"] floatValue] + 6;
                // 胶囊里的关闭按钮的宽度，高度与宽度相等
                if (config[@"uiConfig"][@"capsuleConfig"][@"closeBtnWidth"])
                    uiConfig.capsuleConfig.closeBtnWidth = [config[@"uiConfig"][@"capsuleConfig"][@"closeBtnWidth"] floatValue] - 12;
                // 胶囊里的关闭按钮的左边距
                if (config[@"uiConfig"][@"capsuleConfig"][@"closeBtnLeftMargin"])
                    uiConfig.capsuleConfig.closeBtnLeftMargin = [config[@"uiConfig"][@"capsuleConfig"][@"closeBtnLeftMargin"] floatValue] + 6;
            }
           
            //导航配置
            uiConfig.navHomeConfig = [[FATNavHomeConfig alloc] init];
            if (config[@"uiConfig"][@"navHomeConfig"]) {
                //返回首页按钮宽度，默认44
                if (config[@"uiConfig"][@"navHomeConfig"][@"width"])
                    uiConfig.navHomeConfig.width = [config[@"uiConfig"][@"navHomeConfig"][@"width"] floatValue];
                //返回首页按钮高度，默认32
                if (config[@"uiConfig"][@"navHomeConfig"][@"height"])
                    uiConfig.navHomeConfig.height = [config[@"uiConfig"][@"navHomeConfig"][@"height"] floatValue];
                // 返回首页按钮的左边距，默认7
                if (config[@"uiConfig"][@"navHomeConfig"][@"leftMargin"])
                    uiConfig.navHomeConfig.leftMargin = [config[@"uiConfig"][@"navHomeConfig"][@"leftMargin"] floatValue];
                //返回首页按钮边框圆角半径，默认5
                if (config[@"uiConfig"][@"navHomeConfig"][@"cornerRadius"])
                    uiConfig.navHomeConfig.cornerRadius = [config[@"uiConfig"][@"navHomeConfig"][@"cornerRadius"] floatValue];
                //返回首页按钮边框宽度，默认1
                if (config[@"uiConfig"][@"navHomeConfig"][@"borderWidth"])
                    uiConfig.navHomeConfig.borderWidth = [config[@"uiConfig"][@"navHomeConfig"][@"borderWidth"] floatValue];
                //返回首页按钮浅色边框颜色，默认0X80FFFFFF
                if (config[@"uiConfig"][@"navHomeConfig"][@"borderLightColor"])
                    uiConfig.navHomeConfig.borderLightColor = [self colorWithARGB:config[@"uiConfig"][@"navHomeConfig"][@"borderLightColor"]];
                //返回首页按钮深色边框颜色，默认0X26000000
                if (config[@"uiConfig"][@"navHomeConfig"][@"borderDarkColor"])
                    uiConfig.navHomeConfig.borderDarkColor = [self colorWithARGB:config[@"uiConfig"][@"navHomeConfig"][@"borderDarkColor"]];
                //返回首页按钮浅色背景，默认0x33000000
                if (config[@"uiConfig"][@"navHomeConfig"][@"bgLightColor"])
                    uiConfig.navHomeConfig.borderDarkColor = [self colorWithARGB:config[@"uiConfig"][@"navHomeConfig"][@"bgLightColor"]];
                //返回首页按钮深色背景，默认0x33000000
                if (config[@"uiConfig"][@"navHomeConfig"][@"bgDarkColor"])
                    uiConfig.navHomeConfig.bgDarkColor = [self colorWithARGB:config[@"uiConfig"][@"navHomeConfig"][@"bgDarkColor"]];
            }
            [[FATClient sharedClient] initWithConfig:fatConfig uiConfig:uiConfig error:nil];
        } else
            [[FATClient sharedClient] initWithConfig:fatConfig error:nil];
        
        if (config[@"enableLog"])
            [[FATClient sharedClient] setEnableLog:YES];
        
        //
        [FATClient sharedClient].delegate = [FATClientHelper shareInstance];
        [FATClientHelper shareInstance].mopSdkModule = self;
        
        success(@"success",YES);
    }@catch(NSException *exceptioon) {
        fail(@"fail",NO);
    }@finally{
    }
}
// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(setGrayAppletVersionConfigs:onSuccess:onFail:))
//设置灰度发布
-(void) setGrayAppletVersionConfigs:(NSDictionary *)options onSuccess:(UniModuleKeepAliveCallback) onSuccess onFail:(UniModuleKeepAliveCallback) onFail {
    FATClientHelper *helper = [FATClientHelper shareInstance];
    helper.grayAppletVersionConfigs = options;
    onSuccess(@{@"code":@"success"},YES);
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(setNavigationBarCloseButtonClicked:))
//设置关闭按钮监听
-(void) setNavigationBarCloseButtonClicked:(UniModuleKeepAliveCallback) onCloseButtonClicked {
    FATClientHelper *helper = [FATClientHelper shareInstance];
    helper.onCloseButtonClicked = onCloseButtonClicked;
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(setUserInfo:onSuccess:onFail:))
// 设置用户信息
-(void) setUserInfo:(NSDictionary *) options onSuccess:(UniModuleKeepAliveCallback) onSuccess onFail:(UniModuleKeepAliveCallback) onFail{
    FATClientHelper *helper = [FATClientHelper shareInstance];
    helper.userInfo = options;
    onSuccess(@{@"code":@"success"},YES);
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(setChooseAvatar:))
//设置获取头像
-(void) setChooseAvatar:(UniModuleKeepAliveCallback) onChooseAvatar{
    FATClientHelper *helper = [FATClientHelper shareInstance];
    helper.onChooseAvatar = onChooseAvatar;
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(setGetPhoneNumber:))
//设置获取头像
-(void) setGetPhoneNumber:(UniModuleKeepAliveCallback) onGetPhoneNumber{
    FATClientHelper *helper = [FATClientHelper shareInstance];
    helper.onGetPhoneNumber = onGetPhoneNumber;
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(setRegisteredMoreMenuItems:onRegisteredMoreMenuItemClicked:))
//设置菜单
-(void) setRegisteredMoreMenuItems:(NSDictionary *) options onRegisteredMoreMenuItemClicked:(UniModuleKeepAliveCallback) onRegisteredMoreMenuItemClicked{
    FATClientHelper *helper = [FATClientHelper shareInstance];
    helper.registeredMoreMenuItems = [[NSArray<id<FATAppletMenuProtocol>> alloc ] init];
    //
    helper.onRegisteredMoreMenuItemClicked = onRegisteredMoreMenuItemClicked;
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(setAppletLifecycleCallback:onFailure:onCreate:onStart:onResume:onPause:onStop:onDestroy:))
//设置生命周期
- (void)setAppletLifecycleCallback:(UniModuleKeepAliveCallback)onInitComplete onFailure:(UniModuleKeepAliveCallback)onFailure onCreate:(UniModuleKeepAliveCallback)onCreate onStart:(UniModuleKeepAliveCallback)onStart onResume:(UniModuleKeepAliveCallback)onResume onPause:(UniModuleKeepAliveCallback)onPause onStop:(UniModuleKeepAliveCallback)onStop onDestroy:(UniModuleKeepAliveCallback)onDestroy {
    FATClientHelper *helper = [FATClientHelper shareInstance];
    helper.onInitComplete = onInitComplete;
    helper.onInitComplete = onFailure;
    helper.onInitComplete = onCreate;
    helper.onInitComplete = onStart;
    helper.onInitComplete = onResume;
    helper.onInitComplete = onPause;
    helper.onInitComplete = onStop;
    helper.onInitComplete = onDestroy;
}

// 通过宏 UNI_EXPORT_METHOD_SYNC 将同步方法暴露给 js 端
UNI_EXPORT_METHOD_SYNC(@selector(currentAppletId))
//当前小程序appId
-(NSString*) currentAppletId {
    return [[[FATClient sharedClient] currentApplet] appId];
}

// 通过宏 UNI_EXPORT_METHOD_SYNC 将同步方法暴露给 js 端
UNI_EXPORT_METHOD_SYNC(@selector(currentApplet))
//当前小程序信息
- (NSDictionary *) currentApplet {
    FATAppletInfo *appletInfo = [[FATClient sharedClient] currentApplet];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"appId"] = [appletInfo appId];
    dict[@"appTitle"] = [appletInfo appTitle];
    dict[@"apiServer"] = [appletInfo apiServer];
    dict[@"startParams"] = [appletInfo startParams];
    dict[@"installed"] = [appletInfo installed] ? @"true" : @"false";
    dict[@"sequence"] = [appletInfo sequence];
    dict[@"isGrayRelease"] = [appletInfo isGrayRelease] ? @"true" : @"false";;
    dict[@"versionDescription"] = [appletInfo versionDescription];
    dict[@"appThumbnail"] = [appletInfo appThumbnail];
    dict[@"appVersion"] = [appletInfo appVersion];
    dict[@"appDescription"] = [appletInfo appDescription];
    dict[@"appAvatar"] = [appletInfo appAvatar];
    dict[@"groupId"] = [appletInfo groupId];
    dict[@"userId"] = [appletInfo userId];
    //dict[@"appletVersionType"] = [appletInfo appletVersionType];
    dict[@"cryptInfo"] = [appletInfo cryptInfo];
    return dict;
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(openApplet:appId:startParams:sequence:))
/// 打开小程序（注：异步方法会在主线程（UI线程）执行）
- (void)openApplet:(NSString *)apiServer appId:(NSString *) appId startParams:(NSDictionary *) startParams sequence:(NSNumber *)sequence
{
    @try {
    FATAppletRequest *request = [[FATAppletRequest alloc] init];
    request.appletId = appId;
    request.apiServer = apiServer;
    if (!sequence)
        request.sequence = sequence;
    if (!startParams &&
        !startParams[@"path"] &&
        !startParams[@"query"]) {
         request.startParams = startParams;
    }
    request.transitionStyle = FATTranstionStyleUp;
    
    UIViewController *VC = [self getCurrentVC];
    [[FATClient sharedClient] startAppletWithRequest:request InParentViewController:VC completion:^(BOOL result, FATError *error) {
        NSLog(@"打开小程序:%@", error);
    } closeCompletion:^{
        NSLog(@"关闭小程序");
    }];
    }@catch(NSException *error){
        
    }@finally {
        
    }
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(openAppletByQrcode:onSuccess:onFail:onProgress:))
//二维码打开小程序
- (void)openAppletByQrcode:(NSString *)qrCode onSuccess:(UniModuleKeepAliveCallback) onSuccess onFail:(UniModuleKeepAliveCallback) onFail onProgress:(UniModuleKeepAliveCallback)onProgress
{
    FATAppletQrCodeRequest *qrcodeRequest = [[FATAppletQrCodeRequest alloc] init];
    qrcodeRequest.qrCode = qrCode;
    
    UIViewController *VC = [self getCurrentVC];
    [[FATClient sharedClient] startAppletWithQrCodeRequest:qrcodeRequest inParentViewController:VC requestBlock:^(BOOL result, FATError *error) {
        NSLog(@"请求完成：%@", error);
        if (onSuccess) onSuccess(@{@"code": @"success"}, NO);
    } completion:^(BOOL result, FATError *error) {
        NSLog(@"打开完成：%@", error);
        if (onFail) onFail(@{@"code": @"fail",@"message": [NSString stringWithFormat: @"%ld", error.code]}, NO);
    } closeCompletion:^{
        NSLog(@"关闭");
    }];
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(seachApplets:onSuccess:onFail:onProgress:))
//搜索小程序
- (void)seachApplets:(NSDictionary *)options onSuccess:(UniModuleKeepAliveCallback) onSuccess onFail:(UniModuleKeepAliveCallback) onFail onProgress:(UniModuleKeepAliveCallback)onProgress
{
    //
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(closeApplet:))
//关闭小程序
- (void)closeApplet:(NSString *)appId
{
    [[FATClient sharedClient] closeApplet:appId animated:YES];
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(closeApplets))
//关闭所有小程序信息
- (void)closeApplets
{
    [[FATClient sharedClient] closeAllApplets];
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(finishRunningApplet:))
//清除内存小程序
- (void)finishRunningApplet:(NSString *)appId
{
    [[FATClient sharedClient] clearMemeryApplet:appId];
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(finishAllRunningApplets))
//清队内存所有小程序信息
- (void)finishAllRunningApplets
{
    [[FATClient sharedClient] clearMemoryCache];
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(clearApplets))
//清除缓存中所有小程序信息
- (void)clearApplets
{
    [[FATClient sharedClient] clearLocalApplets];
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(sendCustomEvent:options:))
// 原生发送事件给小程序
- (void)sendCustomEvent:(NSString *) appId options:(NSDictionary *) options
{
    [[FATClient sharedClient].nativeViewManager sendCustomEventWithDetail:options applet:appId completion:^(id result, NSError *error) {
    }];
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(sendCustomEventToAll:))
// 原生发送事件给小程序
- (void)sendCustomEventToAll:(NSDictionary *) options
{
    [[FATClient sharedClient].nativeViewManager sendCustomEventWithDetail:options completion:^(id result, NSError *error) {
    }];
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(callJS:eventName:webViewId:options:onSuccess:onFail:onProcess:))
//原生调用webview中的js方法
- (void)callJS:(NSString *) appId eventName:(NSString *) eventName webViewId:(NSNumber *) webViewId options:(NSDictionary *) options onSuccess:(UniModuleKeepAliveCallback)onSuccess onFail:(UniModuleKeepAliveCallback)onFail onProcess:(UniModuleKeepAliveCallback)onProcess
{
    BOOL isYes = [NSJSONSerialization isValidJSONObject:options];
    if (isYes) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:options options:0 error:NULL];
        NSString *paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [[FATClient sharedClient] fat_callWebApi:eventName paramString:paramString pageId:webViewId handler:^(id result, NSError *error) {
            
        }];
    } else {
        onFail(@{@"code": @"fail",@"message":@"JSON参数格式错误"},NO);
    }
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(registerExtensionApi:callback:))
//注入小程序API
- (void)registerExtensionApi:(NSString *) name callback:(UniModuleKeepAliveCallback)callback
{
    [[FATClient sharedClient] registerExtensionApi:name handle:^(id param, FATExtensionApiCallback extensionCallback) {
        NSString *uuid = [self addExtenssionApiCallback:extensionCallback];
        NSDictionary *dict =  [[NSDictionary alloc] initWithObjectsAndKeys:uuid, @"uuid", nil];
        callback(dict, YES);
    }];
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(registerWebExtentionApi:callback:))
//注入小程序web-view API
- (void)registerWebExtentionApi:(NSString *) name callback:(UniModuleKeepAliveCallback)callback
{
    [[FATClient sharedClient] fat_registerWebApi:name handle:^(id param, FATExtensionApiCallback extensionCallback) {
        NSString *uuid = [self addExtenssionApiCallback:extensionCallback];
        NSDictionary *dict =  [[NSDictionary alloc] initWithObjectsAndKeys:uuid, @"uuid", nil];
        callback(dict, YES);
    }];
}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(onSuccess:options:));
//回调小程序API
- (void)onSuccess:(NSString *) uuid options:(NSDictionary *)options
{
    NSMutableDictionary<NSString*, FATExtensionApiCallback> *map = [self callbackMap];
    for (NSString *name in map)
    {
        if ([name isEqualToString:uuid]) {
            FATExtensionApiCallback extensionCallback = map[uuid];
            if (extensionCallback != nil) {
                extensionCallback(FATExtensionCodeSuccess,options);
            }
            break;
        }
    }
    [map removeObjectForKey:uuid];

}

// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(onFail:options:));
//回调小程序API
- (void)onFail:(NSString *) uuid options:(NSDictionary *)options
{
    NSMutableDictionary<NSString*, FATExtensionApiCallback> *map = [self callbackMap];
    for (NSString *name in map)
    {
        if ([name isEqualToString:uuid]) {
            FATExtensionApiCallback extensionCallback = map[uuid];
            if (extensionCallback != nil) {
                extensionCallback(FATExtensionCodeFailure,options);
            }
            break;
        }
    }
    [map removeObjectForKey:uuid];
}

- (NSString *) addExtenssionApiCallback:(FATExtensionApiCallback) extensionCallback
{
    if (self.callbackMap == nil) {
        self.callbackMap = [[NSMutableDictionary alloc] init];
    }
    NSString *uuid = [self uuidString];
    self.callbackMap[uuid] = extensionCallback;
    
    return uuid;
}

@end
