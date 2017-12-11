//
//  YSRepeatCaller.h
//  KDS_Phone
//
//  Created by sylvan on 2017/8/18.
//  Copyright © 2017年 liys. All rights reserved.
//
//重复回调
#import <Foundation/Foundation.h>

//默认时间间隔
#define DEF_RefreshTimeIntervel  5.f

typedef void(^YSRepeatCallBackBlock)(id callTarget);
typedef void(^YSRepeatCallBackBlock2)(void);

#pragma mark - @protocol YSRepeatCallerMemoryManage

@class YSRepeatCaller;
@protocol YSRepeatCallerMemoryManage <NSObject>

-(YSRepeatCaller *)repeatCallerWithID:(NSString *)stringId;
-(void)freeRepeatCallerWithID:(NSString *)stringId;
-(void)saveRepeatCaller:(YSRepeatCaller *)repeatCaller withID:(NSString *)stringId;

@optional
-(NSArray<YSRepeatCaller *> *)repeatCallers;
-(NSArray<YSRepeatCaller *> *)repeatCallerWithMethod:(SEL)method;

@end

#pragma mark - NSObject (YSRepeatCaller)<YSRepeatCallerMemoryManage>

@interface NSObject (YSRepeatCaller)<YSRepeatCallerMemoryManage>

/** 推荐使用 */
-(YSRepeatCaller *)repeatCallerWithMethod:(SEL)method;
- (void)startRepeatCallMethod:(SEL)method;
- (void(^)(NSNumber * timeInterval))startRepeatCallMethod2:(SEL)method;
- (void)stopRepeatCallMethod:(SEL)method;

/** 推荐使用 */
-(YSRepeatCaller *)repeatCallerWithBlock;
- (void)startRepeatCallBlock:(YSRepeatCallBackBlock2)block;
- (void(^)(NSNumber * timeInterval))startRepeatCallBlock2:(YSRepeatCallBackBlock2)block;
- (void)stopRepeatCallBlock;
@end


#pragma mark - YSRepeatCaller

@interface YSRepeatCaller : NSObject

/** 默认为NO。忽略下次回调*/
@property (nonatomic, assign) BOOL ignoreNextCallBack;

/** 默认为NO。忽略状态 */
@property (nonatomic, assign) BOOL ignoreStatus;

/** 默认为NO。当autoIgnoreNextCallbackForIgnoreStatus 设为Yes,则当ignoreStatus为Yes,则自动跳过下次 */
@property (nonatomic, assign) BOOL autoIgnoreNextCallbackForIgnoreStatus;

/** 默认为NO。全局忽略状态 当ignoreStatusGlobal为Yes 全部的YSRepeatCaller都会忽略回调*/
@property (nonatomic, assign, class) BOOL ignoreStatusGlobal;

/** 默认为NO。当autoIgnoreNextCallbackExculutionIgnoreStatusGlobal 设为Yes,不管 ignoreStatusGlobal 是否为Yes 都 根据ignoreStatus和ignoreNextCallBack 执行 下一次回调*/
@property (nonatomic, assign) BOOL autoIgnoreNextCallbackExculutionIgnoreStatusGlobal;

/** 重复调用间隔时间 */
@property (nonatomic, assign) NSTimeInterval timeInterval;

/** 重复调用间隔时间 全局忽略时间 ，YSRepeatCaller 初始化 时若timeIntervalGlobalInitValue大于0，则初始化timeInterval 为timeIntervalGlobalInitValue 否则 为DEF_RefreshTimeIntervel*/
@property (nonatomic, assign, class) NSTimeInterval timeIntervalGlobalInitValue;

/** method 回调对象 */
@property (nonatomic, weak) __kindof NSObject * callTarget;

/** YSRepeatCaller的依存对象*/
@property (nonatomic, weak) id<YSRepeatCallerMemoryManage> repeatCallerMemoryManage;

/** 需要调用的方法(仅支持无参方法)，default call @selector(autoRefresh) */
@property (nonatomic, assign) SEL method;

@property (nonatomic, copy) YSRepeatCallBackBlock callBackBlock;

//YSRepeatCaller的唯一标示，配合method，或者callBackBlock
@property (nonatomic, strong) NSString * stringId;

/** 开始调用 */
- (void)start;

/** 移除调用 */
- (void)stop;

/** 立即触发 */
- (void)fire;

/** 释放自己 */
- (void)free;

/** 便利构造器 */
+ (instancetype)repeatCallerId:(NSString *)stringid memoryManage:(id<YSRepeatCallerMemoryManage>)memoryManage;

//other map YSRepeatCallerMemoryManage
+ (void)stopWithID:(NSString *)stringid fromMemoryManage:(id<YSRepeatCallerMemoryManage>)memoryManage;
+ (void)freeWithID:(NSString *)stringid fromMemoryManage:(id<YSRepeatCallerMemoryManage>)memoryManage;

//不一定可用，看id<YSRepeatCallerMemoryManage>实现的方法
+ (void)stopWithMethod:(SEL)method fromMemoryManage:(id<YSRepeatCallerMemoryManage>)memoryManage;
+ (void)freeWithMethod:(SEL)method fromMemoryManage:(id<YSRepeatCallerMemoryManage>)memoryManage;
+ (void)stopAllRepeatCallerFromMemoryManage:(id<YSRepeatCallerMemoryManage>)memoryManage;
+ (void)freeAllRepeatCallerFromMemoryManage:(id<YSRepeatCallerMemoryManage>)memoryManage;

@end


