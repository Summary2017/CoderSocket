//
//  UdpSocket.m
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

#import "UdpSocket.h"
#import "GCDAsyncUdpSocket.h"

// 全局变量
static uint16_t const kPORT = 8099;
static NSString* const kHOST = @"255.255.255.255";

@interface UdpSocket () <GCDAsyncUdpSocketDelegate>

// 发送block
@property (nonatomic, copy) void(^sendBlock)(NSError *error);
// 接收block
@property (nonatomic, copy) void(^receiveBlock)(NSData *data, NSString *host);
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;

@end

@implementation UdpSocket

static UdpSocket *_instance = nil;

// 简单实现 单例的相关实现, 请看我的简书 [iOS单例的精心设计历程](https://www.jianshu.com/p/e18d1518db65)
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        [_instance setupBase];
    });
    return _instance;
}

- (void)setupBase {
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}


- (void)sendData:(NSData *)data sendBlock:(void(^)(NSError *error))sendBlock
{
    if (self.sendBlock) self.sendBlock = nil;
    if ([self.udpSocket isConnected]) [self.udpSocket close];
    __weak UdpSocket *weakSelf = self;
    self.sendBlock = ^(NSError *error) {
        
        if (sendBlock) sendBlock(error);
        weakSelf.sendBlock = nil;
    };
    // 通过广播的形式发送
    [self.udpSocket enableBroadcast:YES error:nil];
    [self.udpSocket sendData:data toHost:kHOST port:kPORT withTimeout:-1 tag:0];
}

- (void)receiveUdpDataWithReceiveBlock:(void(^)(NSData *data, NSString *host))receiveBlock
{
    if (self.receiveBlock) self.receiveBlock = nil;
    if ([self.udpSocket isConnected]) [self.udpSocket close];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        __weak UdpSocket *weakSelf = self;
        self.receiveBlock = ^(NSData *data, NSString *host) {
            
            if (receiveBlock) receiveBlock(data, host);
            weakSelf.receiveBlock = nil;
        };
        // 注册端口
        [self.udpSocket bindToPort:kPORT error:nil];
        // 接收
        [self.udpSocket beginReceiving:nil];
        //        [self.udpSocket receiveOnce:nil];
    });
}


#pragma mark - GCDAsyncUdpSocket
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    // 发送成功之后关闭，然后开启监听端口
    [sock close];
    [sock beginReceiving:nil];
    if (self.sendBlock)
    {
        self.sendBlock(nil);
    }
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    if (self.sendBlock)
    {
        self.sendBlock(error);
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSString *host = nil;
    uint16_t port = kPORT;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    NSLog(@"%@", host);
    if (self.receiveBlock)
    {
        self.receiveBlock(data, host);
    }
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    if (self.sendBlock)
    {
        self.sendBlock(error);
    }
}

- (void)disconnect
{
    self.sendBlock = nil;
    self.receiveBlock = nil;
    [self.udpSocket close];
}

@end
