//
//  TCPClientSocket.h
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//  可以作为: iOS->安卓 iOS作为客户端，连接socket，并发送文件

#import <Foundation/Foundation.h>

@interface TCPClientSocket : NSObject

/**
 初始化TCP连接客户端对象
 
 @return 客户端对象
 */
+ (instancetype)sharedInstance;

/**
 连接host，并发送文件
 
 @param host 服务器主机地址
 @param fileInfo 文件信息
 @param sendBlock 发送回调
 */
- (void)connectToSendFile:(NSString *)host FileInfo:(NSDictionary *)fileInfo SendBlock:(void(^)(NSError *))sendBlock;

/**
 断开连接
 */
- (void)disconnect;

@end
