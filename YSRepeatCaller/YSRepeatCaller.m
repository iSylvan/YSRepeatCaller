//
//  YSRepeatCaller.m
//  KDS_Phone
//
//  Created by sylvan on 2017/8/18.
//  Copyright © 2017年 liys. All rights reserved.
//

#import "YSRepeatCaller.h"
#import <objc/message.h>
#import <objc/runtime.h>

#pragma mark - NSObject (YSRepeatCaller)<YSRepeatCallerMemoryManage>

const NSString * repeatCallers_KEY = @"____repeatCallers____";

@interface NSObject()
@property(nonatomic,strong)NSMutableDictionary<NSString *,YSRepeatCaller *> *repeatCallers;
@end

@implementation NSObject (YSRepeatCaller)

#pragma mark <YSRepeatCallerMemoryManage>

-(NSMutableDictionary<NSString *,YSRepeatCaller *> *)repeatCallers{
    id obj = objc_getAssociatedObject(self, (__bridge const void *)repeatCallers_KEY);
    if (!obj||![obj isKindOfClass:[NSDictionary class]])  {
        obj = [@{} mutableCopy];
        [self setRepeatCallers:obj];
    }
    return obj;
}

-(void)setRepeatCallers:(NSMutableDictionary<NSString *,YSRepeatCaller *> *)repeatCallers{
    objc_setAssociatedObject(self, (__bridge const void *)repeatCallers_KEY, repeatCallers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)saveRepeatCaller:(YSRepeatCaller *)repeatCaller withID:(NSString *)stringId{
    if (!stringId) return;
    [self.repeatCallers setObject:repeatCaller forKey:stringId];
}

-(YSRepeatCaller *)repeatCallerWithID:(NSString *)stringId{
    if (!stringId) return nil;
    id obj =  [self.repeatCallers objectForKey:stringId];
    if ([obj isKindOfClass:[YSRepeatCaller class]]) {
        return (YSRepeatCaller *)obj;
    }
    return nil;
}

-(void)freeRepeatCallerWithID:(NSString *)stringId{
     if (!stringId) return;
    [self.repeatCallers removeObjectForKey:stringId];
}

#pragma mark public

-(YSRepeatCaller *)repeatCallerWithMethod:(SEL)method{
    NSString * stringId = NSStringFromSelector(method);
    YSRepeatCaller * repeatCaller  = [self repeatCallerWithID:stringId];
    if (!repeatCaller) {
        repeatCaller = [YSRepeatCaller repeatCallerId:stringId memoryManage:self];
        repeatCaller.callTarget = self;//执行对象
        repeatCaller.method = method;//执行方法
    }
    return repeatCaller;
}

- (void)startRepeatCallMethod:(SEL)method{
    YSRepeatCaller * repeatCaller  = [self repeatCallerWithMethod:method];
    [repeatCaller start];
}

- (void(^)(NSNumber * timeInterval))startRepeatCallMethod2:(SEL)method{
    YSRepeatCaller * repeatCaller  = [self repeatCallerWithMethod:method];
    return ^(NSNumber * timeInterval){
        if (timeInterval) {
             repeatCaller.timeInterval = timeInterval.doubleValue;//时间间隔
        }
        [repeatCaller start];
    };
}

- (void)stopRepeatCallMethod:(SEL)method{
    NSString * stringId = NSStringFromSelector(method);
    [self stopRepeatCallWithID:stringId];
}

-(YSRepeatCaller *)repeatCallerWithBlock{
    NSString * stringId = @"YT_RepeatCallBlock_One";
    YSRepeatCaller * repeatCaller  = [self repeatCallerWithID:stringId];
    if (!repeatCaller) {
        repeatCaller = [YSRepeatCaller repeatCallerId:stringId memoryManage:self];
    }
    return repeatCaller;
}

- (void)startRepeatCallBlock:(YSRepeatCallBackBlock2)block{
    YSRepeatCaller * repeatCaller  = [self repeatCallerWithBlock];
    [repeatCaller setCallBackBlock:^(id target) {
        block();
    }];
    [repeatCaller start];
}

- (void(^)(NSNumber * timeInterval))startRepeatCallBlock2:(YSRepeatCallBackBlock2)block{
    YSRepeatCaller * repeatCaller  = [self repeatCallerWithBlock];
    [repeatCaller setCallBackBlock:^(id target) {
        block();
    }];
    return ^(NSNumber * timeInterval){
        if (timeInterval) {
            repeatCaller.timeInterval = timeInterval.doubleValue;//时间间隔
        }
        [repeatCaller start];
    };
}

- (void)stopRepeatCallBlock{
    NSString * stringId = @"YT_RepeatCallBlock_One";
    [self stopRepeatCallWithID:stringId];
}

- (void)stopRepeatCallWithID:(NSString *)stringId{
    YSRepeatCaller * repeatCaller  = [self repeatCallerWithID:stringId];
    if (repeatCaller) {
        [repeatCaller stop];
    }
}

@end

#pragma mark - YSRepeatCaller

@interface YSRepeatCaller ()

@property (nonatomic, weak) NSTimer *timer;

@end

@implementation YSRepeatCaller

#pragma mark class

static bool YSRepeatCaller_ignoreStatusGlobal;
static NSTimeInterval YSRepeatCaller_timeIntervalGlobalInitValue;

+(BOOL)ignoreStatusGlobal{
    return YSRepeatCaller_ignoreStatusGlobal;
}

+(void)setIgnoreStatusGlobal:(BOOL)ignoreStatusGlobal{
    YSRepeatCaller_ignoreStatusGlobal = ignoreStatusGlobal;
}

+(NSTimeInterval)timeIntervalGlobalInitValue{
    return YSRepeatCaller_timeIntervalGlobalInitValue;
}

+(void)setTimeIntervalGlobalInitValue:(NSTimeInterval)timeIntervalGlobalInitValue{
    YSRepeatCaller_timeIntervalGlobalInitValue = timeIntervalGlobalInitValue;
}

#pragma mark init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self makeDefConfig];
    }
    return self;
}

-(void)makeDefConfig{
    //默认时间间隔
    if (self.class.timeIntervalGlobalInitValue > 0) {
        self.timeInterval = self.class.timeIntervalGlobalInitValue;
    }else{
        self.timeInterval = DEF_RefreshTimeIntervel;
    }
}

-(NSTimer *)timer{
    if (self.timeInterval<=0) return nil;
    if (!_timer) {
      _timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(repeat) userInfo:nil repeats:YES];
    }
    return _timer;
}

-(void)setRepeatCallerMemoryManage:(id<YSRepeatCallerMemoryManage>)repeatCallerMemoryManage{
    _repeatCallerMemoryManage = repeatCallerMemoryManage;
    [repeatCallerMemoryManage saveRepeatCaller:self withID:self.stringId];
}

-(void)setStringId:(NSString *)stringId{
    if (self.repeatCallerMemoryManage) {
        [self.repeatCallerMemoryManage freeRepeatCallerWithID:self.stringId];
    }
    [_repeatCallerMemoryManage saveRepeatCaller:self withID:stringId];
    _stringId = stringId;
}

- (void)repeat{
    if (self.class.ignoreStatusGlobal&&self.autoIgnoreNextCallbackExculutionIgnoreStatusGlobal == NO) return;
    if (self.autoIgnoreNextCallbackForIgnoreStatus&&self.ignoreStatus) return;
    if(self.ignoreNextCallBack){self.ignoreNextCallBack = NO; return ;}
    if (_method&&_callTarget) {
        NSAssert([ NSStringFromSelector(_method) rangeOfString:@":"].location == NSNotFound, @"-[%@ %@]: Only supports the methods with zero the arguments.", NSStringFromClass(_callTarget.class), NSStringFromSelector(_method));
        if ([_callTarget respondsToSelector:_method]) {
//           ((void(*)(id, SEL))objc_msgSend)(_callTarget, _method);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_callTarget performSelector:_method];
#pragma clang diagnostic pop
            
        }else{
            NSLog(@"-[%@ %@]: unrecognized method.", NSStringFromClass(_callTarget.class), NSStringFromSelector(_method));
        }
    }
    if (self.callBackBlock) {
        self.callBackBlock(_callTarget);
    }
    
}

- (void)start {
    [self stop];
    if (self.timer) {
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stop {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)fire {
    [_timer fire];
}

- (void)free{
    if (self.repeatCallerMemoryManage) {
        [self.repeatCallerMemoryManage freeRepeatCallerWithID:self.stringId];
    }
}

-(void)dealloc{
    [self stop];
}

/** 便利构造器 */
+ (instancetype)repeatCallerId:(NSString *)stringid memoryManage:(id<YSRepeatCallerMemoryManage>)memoryManage{
     YSRepeatCaller * obj =  [[YSRepeatCaller alloc]init];
     obj.stringId = stringid;
     obj.repeatCallerMemoryManage = memoryManage;
     return obj;
}

#pragma mark map YSRepeatCallerMemoryManage

+ (void)stopWithID:(NSString *)stringid fromMemoryManage:(id<YSRepeatCallerMemoryManage>)memoryManage{
    if (memoryManage) {
        [[memoryManage repeatCallerWithID:stringid] stop];
    }
}
+ (void)freeWithID:(NSString *)stringid fromMemoryManage:(id<YSRepeatCallerMemoryManage>)memoryManage{
    if (memoryManage) {
        [[memoryManage repeatCallerWithID:stringid] free];
    }
}

//不一定可用，看id<YSRepeatCallerMemoryManage>实现的方法
+ (void)stopWithMethod:(SEL)method fromMemoryManage:(id<YSRepeatCallerMemoryManage>)memoryManage{
    if (memoryManage&&[memoryManage respondsToSelector:@selector(repeatCallerWithMethod:)]) {
        [[memoryManage repeatCallerWithMethod:method] enumerateObjectsUsingBlock:^(YSRepeatCaller * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj stop];
        }];
    }
}
+ (void)freeWithMethod:(SEL)method fromMemoryManage:(id<YSRepeatCallerMemoryManage>)memoryManage{
    if (memoryManage&&[memoryManage respondsToSelector:@selector(repeatCallerWithMethod:)]) {
        [[memoryManage repeatCallerWithMethod:method] enumerateObjectsUsingBlock:^(YSRepeatCaller * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj free];
        }];
    }
}
+ (void)stopAllRepeatCallerFromMemoryManage:(id<YSRepeatCallerMemoryManage>)memoryManage{
    if (memoryManage&&[memoryManage respondsToSelector:@selector(repeatCallers)]) {
        [memoryManage.repeatCallers enumerateObjectsUsingBlock:^(YSRepeatCaller * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj stop];
        }];
    }
}
+ (void)freeAllRepeatCallerFromMemoryManage:(id<YSRepeatCallerMemoryManage>)memoryManage{
    if (memoryManage&&[memoryManage respondsToSelector:@selector(repeatCallers)]) {
        [memoryManage.repeatCallers enumerateObjectsUsingBlock:^(YSRepeatCaller * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj free];
        }];
    }
}

@end
