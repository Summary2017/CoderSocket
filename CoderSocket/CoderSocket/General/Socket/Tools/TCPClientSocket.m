//
//  TCPClientSocket.m
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

#import "TCPClientSocket.h"
#import "GCDAsyncSocket.h"
#import "ClientFileInfoModel.h"

@interface TCPClientSocket () <GCDAsyncSocketDelegate>

// 多个客户端
@property (nonatomic, strong) NSMutableArray <ClientFileInfoModel *>*clientSocketArray;

@end

@implementation TCPClientSocket

static TCPClientSocket *_instance = nil;

// 简单实现 单例的相关实现, 请看我的简书 [iOS单例的精心设计历程](https://www.jianshu.com/p/e18d1518db65)
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        [_instance setupBase];
    });
    return _instance;
}

- (void)setupBase
{
    self.clientSocketArray = [NSMutableArray array];
}


- (void)connectToSendFile:(NSString *)host FileInfo:(NSDictionary *)fileInfo SendBlock:(void (^)(NSError *))sendBlock
{
    GCDAsyncSocket *clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    clientSocket.delegate = self;
    ClientFileInfoModel *infoModel = [[ClientFileInfoModel alloc] init];
    infoModel.clientSocket = clientSocket;
    infoModel.fileInfo = fileInfo;
    __weak ClientFileInfoModel *weakInfoModel = infoModel;
    infoModel.connectBlock = ^(NSError *error) {
        
        if (!error) {
            
            weakInfoModel.sendBlock = ^{
                
                if (sendBlock) sendBlock(nil);
            };
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:weakInfoModel.fileInfo options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSData *headerData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSInteger restIndex = 10240 - headerData.length;
            NSMutableString *totalString = [NSMutableString stringWithString:jsonStr];
            for (NSInteger i = 0; i < restIndex; i++)
            {
                [totalString appendString:@" "];
            }
            NSMutableData *dataM = [NSMutableData dataWithData:[totalString dataUsingEncoding:NSUTF8StringEncoding]];
            [dataM appendData:[NSData dataWithContentsOfFile:weakInfoModel.fileInfo[@"path"]]];
            // 发送文件
            [weakInfoModel.clientSocket writeData:dataM withTimeout:-1 tag:0];
        }
    };
    [self.clientSocketArray addObject:infoModel];
    NSError *error = nil;
    // -1无穷大
    [clientSocket connectToHost:host onPort:8080 withTimeout:-1 error:&error];
}


- (void)disconnect
{
    [self.clientSocketArray enumerateObjectsUsingBlock:^(ClientFileInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [obj.clientSocket disconnect];
    }];
    [self.clientSocketArray removeAllObjects];
}


#pragma mark - GCDAsyncSocketDelegate
// 1.与主机连接成功
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(ClientFileInfoModel *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        return [evaluatedObject.clientSocket isEqual:sock];
    }];
    NSArray *filterArray = [self.clientSocketArray filteredArrayUsingPredicate:predicate];
    if (filterArray.count > 0)
    {
        ClientFileInfoModel *infoModel = filterArray.firstObject;
        [infoModel.clientSocket readDataWithTimeout:-1 tag:0];
        if (infoModel.connectBlock) infoModel.connectBlock(nil);
    }
}

// 连接失败
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(ClientFileInfoModel *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        return [evaluatedObject.clientSocket isEqual:sock];
    }];
    NSArray *filterArray = [self.clientSocketArray filteredArrayUsingPredicate:predicate];
    if (filterArray.count > 0)
    {
        ClientFileInfoModel *infoModel = filterArray.firstObject;
        [infoModel.clientSocket readDataWithTimeout:-1 tag:0];
        if (infoModel.connectBlock) infoModel.connectBlock(err);
    }
}


// 发送消息成功
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(ClientFileInfoModel *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        return [evaluatedObject.clientSocket isEqual:sock];
    }];
    NSArray *filterArray = [self.clientSocketArray filteredArrayUsingPredicate:predicate];
    if (filterArray.count > 0)
    {
        ClientFileInfoModel *infoModel = filterArray.firstObject;
        [self.clientSocketArray removeObject:infoModel];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [infoModel.clientSocket disconnect];
//        });
        if (infoModel.sendBlock) infoModel.sendBlock();
    }
}

// 2.收到消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"%zd", data.length);
}

@end
