//
//  TCPServerSocket.h
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//  可以作为: 安卓->iOS iOS作为服务端，等待收文件

#import <Foundation/Foundation.h>
@class ServerFileInfoModel;

@interface TCPServerSocket : NSObject

/**
 初始化一个TCP连接服务端对象
 
 @return 服务端对象
 */
+ (instancetype)sharedInstance;

/**
 TCP连接监听
 
 @param connectBlock 连接结果回调
 */
- (void)startListenningWithConnectBlock:(void(^)(NSError *error))connectBlock;

/**
 接收客户端数据
 
 @param receiveBlock 接收回调
 */
- (void)receivedDataWithReceiveBlock:(void (^)(NSError *error, ServerFileInfoModel *infoModel))receiveBlock;

/**
 断开连接
 */
- (void)disconnect;

@end
