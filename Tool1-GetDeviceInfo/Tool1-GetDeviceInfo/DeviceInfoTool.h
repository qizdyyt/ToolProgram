//
//  DeviceInfoTool.h
//  ToolProgram
//
//  Created by qizidong on 2017/8/14.
//  Copyright © 2017年 zidong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DeviceInfoTool : NSObject

///屏幕宽度
+ (CGFloat)getDeviceScreenWidth;
///屏幕高度
+ (CGFloat)getDeviceScreenHeight;
///获取设备版本号
+ (NSString *)getDeviceName;
///获取iPhone名称
+ (NSString *)getiPhoneName;
///获取app版本号
+ (NSString *)getAppVersion;
///获取电池电量
+ (CGFloat)getBatteryLevel;
///获取系统名称
+ (NSString *)getSystemName;
///当前系统版本号
+ (NSString *)getSystemVersion;
///获取通用唯一识别码UUID
+ (NSString *)getUUID;
///获取当前设备IP
+ (NSString *)getDeviceIPAddress;
///获取总内存大小
+ (long long)getTotalMemorySize;
/// 获取当前可用内存
+ (long long)getAvailableMemorySize;
///获取精准电池电量
+ (CGFloat) getCurrentBatteryLevel;
///获取电池当前状态。4种
+ (NSString *)getBatteryState;
///获取当前语言
+ (NSString *)getDeviceLanguage;

+ (void) testFuncWithFuncName: (NSString *)name type: (int)type;

@end
