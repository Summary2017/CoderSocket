//
//  PhotoAssetsModel.h
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class PHAsset;

typedef NS_ENUM(NSUInteger, PhotoMediaType){
    PhotoMediaImage,
    PhotoMediaVideo,
};

@interface PhotoAssetsModel : NSObject


// 初始化模型
+ (instancetype)photoWithAssets:(PHAsset *)asset;

// 资源对象
@property (nonatomic, strong, readonly) PHAsset *passet;

// 资源创建时间
@property (nonatomic, strong) NSDate *asset_creationDate;

// 资源名字
@property (nonatomic, copy) NSString *fileName;

// 资源路径
@property (nonatomic, copy) NSString *filePath;

// 资源路径url
@property (nonatomic, strong) NSURL *fileUrl;

// 资源大小
@property (nonatomic) NSInteger fileLength;

// 资源data
@property (nonatomic, strong) NSData *fileData;

// 缩略图
@property (nonatomic, strong) UIImage *thumImage;

// 缩略图尺寸
@property (nonatomic, assign) CGSize thumImageSize;

// 原图
@property (nonatomic, strong) UIImage *origImage;

// 视频资源
@property (nonatomic, strong) AVAsset *avasset;

// 音频资源
@property (nonatomic, strong) AVAudioMix *audioAsset;

// 资源类型
@property (nonatomic, assign, readonly) PhotoMediaType assetType;
// 资源类型字符串
@property (nonatomic, copy) NSString *assetTypeStr;

@property (nonatomic, assign, getter=selected) BOOL isSelected;

@end
