//
//  ClientFileInfoModel.h
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface ClientFileInfoModel : NSObject

// 对应的客户端
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
// 文件信息 (name, size, path)
@property (nonatomic, strong) NSDictionary *fileInfo;
// 连接成功回调
@property (nonatomic, copy) void(^connectBlock)(NSError *error);
// 发送成功回调
@property (nonatomic, copy) void(^sendBlock)(void);

@end
