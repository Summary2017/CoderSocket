//
//  NetWorkListener.m
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

#import "NetWorkListener.h"

@interface NetWorkListener ()

@property (nonatomic, copy) void (^reachBlock)(void);
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation NetWorkListener

static NetWorkListener *_instance = nil;

// 简单实现 单例的相关实现, 请看我的简书 [iOS单例的精心设计历程](https://www.jianshu.com/p/e18d1518db65)
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

/**
 开始监听状态变化
 */
- (void)startListenningWithReachabilityBlock:(void(^)(void))reachBlock {
    if (self.timer) return;
    self.reachBlock = reachBlock;
    
    // 先停止, 其实有这一句(if (self.timer) return;), 也没有必要先停止的
    [self stopListenning];
    
    if (reachBlock) {
        // 没有的话直接返回, 因为定时就木有意义了
        return;
    }
    
    // 开启时间
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerSet:) userInfo:nil repeats:YES];
    // 切换模式
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)timerSet:(NSTimer *)timer {
    if (self.reachBlock)
    {
        self.reachBlock();
    }
}

/**
 停止监听
 */
- (void)stopListenning {
    self.reachBlock = nil;
    [self.timer invalidate];
    self.timer = nil;
}

@end
