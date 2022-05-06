//
//  TestModule.h
//  DCTestUniPlugin
//
//  Created by XHY on 2020/4/22.
//  Copyright © 2020 DCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FinApplet/FinApplet.h>

#import "DCUniModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface MopSdkModule : DCUniModule

@property (nonatomic, strong) NSMutableDictionary<NSString*,FATExtensionApiCallback> *callbackMap;


- (NSString *) addExtenssionApiCallback:(FATExtensionApiCallback) extensionCallback;

@end

NS_ASSUME_NONNULL_END
