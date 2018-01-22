//
//  TCPServerSocket.m
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//  

#import "TCPServerSocket.h"
#import "GCDAsyncSocket.h"
#import "ServerFileInfoModel.h"

@interface TCPServerSocket () <GCDAsyncSocketDelegate>

@property (nonatomic, copy) void (^receiveBlock)(NSError *error, ServerFileInfoModel *infoModel);
@property (nonatomic, copy) void (^connectBlock)(NSError *error);

@property (nonatomic, strong) GCDAsyncSocket *serverSocket;

// 保存的客户端socket数据
@property (nonatomic, strong) NSMutableArray <ServerFileInfoModel *>*clientSocketArray;

@end

@implementation TCPServerSocket

static TCPServerSocket *_instance = nil;

// 简单实现 单例的相关实现, 请看我的简书 [iOS单例的精心设计历程](https://www.jianshu.com/p/e18d1518db65)
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        [_instance setupBase];
    });
    return _instance;
}

- (void)setupBase
{
    self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.serverSocket.delegate = self;
    self.clientSocketArray = [NSMutableArray array];
}

- (void)startListenningWithConnectBlock:(void(^)(NSError *error))connectBlock
{
    if (self.connectBlock) self.connectBlock = nil;
    if ([self.serverSocket isConnected]) [self.serverSocket disconnect];
    
    NSError *error = nil;
    [self.serverSocket acceptOnPort:8080 error:&error];
    if (error)
    {
        if (connectBlock) connectBlock(error);
        return ;
    }
    __weak TCPServerSocket *weakSelf = self;
    self.connectBlock = ^(NSError *error) {
        
        if (connectBlock) connectBlock(error);
        weakSelf.connectBlock = nil;
    };
}

- (void)receivedDataWithReceiveBlock:(void (^)(NSError *error, ServerFileInfoModel *infoModel))receiveBlock
{
    if (self.receiveBlock) self.receiveBlock = nil;
    self.receiveBlock = ^(NSError *error, ServerFileInfoModel *infoModel) {
        
        if (receiveBlock) receiveBlock(error, infoModel);
    };
}

- (void)disconnect
{
    [self.serverSocket disconnectAfterReading];
    if (self.receiveBlock) self.receiveBlock = nil;
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"收到新socket: ++%@", newSocket);
    if (self.connectBlock) self.connectBlock(nil);
    ServerFileInfoModel *fileInfoModel = [[ServerFileInfoModel alloc] init];
    fileInfoModel.clientSocket = newSocket;
    [self.clientSocketArray addObject:fileInfoModel];
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(ServerFileInfoModel *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        return [evaluatedObject.clientSocket isEqual:sock];
    }];
    NSArray *filterArray = [self.clientSocketArray filteredArrayUsingPredicate:predicate];
    NSLog(@"%@-%zd", filterArray, filterArray.count);
    if (filterArray.count > 0)
    {
        ServerFileInfoModel *fileInfo = filterArray.firstObject;
        [fileInfo.fileData appendData:data];
        if (fileInfo.isFinished)
        {
            NSLog(@"***接收完成***");
            [self.clientSocketArray removeObject:fileInfo];
        }
        [fileInfo.clientSocket readDataWithTimeout:-1 tag:0];
        if (self.receiveBlock) self.receiveBlock(nil, fileInfo);
    }
}

@end
