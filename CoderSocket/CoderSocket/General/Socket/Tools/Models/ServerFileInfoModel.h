//
//  ServerFileInfoModel.h
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCDAsyncSocket;

@interface ServerFileInfoModel : NSObject

@property (nonatomic, strong) NSMutableData *fileData;
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;

@property (nonatomic, assign) BOOL isFinished;

@end
