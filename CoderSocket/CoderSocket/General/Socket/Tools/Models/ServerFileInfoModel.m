//
//  ServerFileInfoModel.m
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

#import "ServerFileInfoModel.h"
#import "GCDAsyncSocket.h"

@implementation ServerFileInfoModel

- (instancetype)init
{
    if (self = [super init])
    {
        self.fileData = [NSMutableData data];
    }
    return self;
}

- (BOOL)isFinished
{
    if (self.fileData.length > 10240)
    {
        NSData *headerData = [self.fileData subdataWithRange:NSMakeRange(0, 1024 * 10)];
        NSString *originInfo = [[NSString alloc] initWithData:headerData encoding:NSUTF8StringEncoding];
        NSString *fixInfo = [originInfo stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        NSDictionary *fileInfo = [NSJSONSerialization JSONObjectWithData:[fixInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        return [fileInfo[@"size"] floatValue] == (self.fileData.length - 10240);
    }
    return NO;
}

@end
