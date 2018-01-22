//
//  NetWorkListener.h
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

/**
 实时心跳监听的工具
 */

#import <Foundation/Foundation.h>

@interface NetWorkListener : NSObject

/**
 初始化状态变化监听者
 
 @return 监听者对象
 */
+ (instancetype)sharedInstance;


/**
 开始监听状态变化
 
 @param reachBlock 网络可达回调
 */
- (void)startListenningWithReachabilityBlock:(void(^)(void))reachBlock;

/**
 停止监听
 */
- (void)stopListenning;

@end
