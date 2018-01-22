//
//  UdpSocket.h
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdpSocket : NSObject

+ (instancetype)sharedInstance;

/**
 通过广播形式发送报文
 
 @param data 数据
 @param sendBlock 发送回调
 */
- (void)sendData:(NSData *)data sendBlock:(void(^)(NSError *error))sendBlock;


/**
 接收udp报文数据
 
 @param receiveBlock 接收回调
 */
- (void)receiveUdpDataWithReceiveBlock:(void(^)(NSData *data, NSString *host))receiveBlock;

/**
 断开udp通讯
 */
- (void)disconnect;

@end
