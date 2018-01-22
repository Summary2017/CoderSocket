//
//  PhotoAssetsModel.m
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

#import "PhotoAssetsModel.h"
#import <Photos/Photos.h>

@implementation PhotoAssetsModel

/// 初始化
+ (instancetype)photoWithAssets:(PHAsset *)asset {
    
    PhotoAssetsModel *assetModel = [[self alloc] init];
    assetModel.passet = asset;
    
    return assetModel;
}

- (void)setPasset:(PHAsset *)passet {
    
    _passet = passet;
    
    if (_passet.mediaType == PHAssetMediaTypeImage) {
        self.assetType = PhotoMediaImage;
        
    }
    if (_passet.mediaType == PHAssetMediaTypeVideo) {
        self.assetType = PhotoMediaVideo;
    }
    self.thumImageSize = CGSizeMake(passet.pixelWidth, passet.pixelHeight);
}

- (void)setAssetType:(PhotoMediaType)assetType {
    _assetType = assetType;
    self.assetTypeStr = [NSString stringWithFormat:@"%zd", assetType];
}

- (NSDate *)asset_creationDate {
    if (_asset_creationDate == nil)
    {
        _asset_creationDate = self.passet.creationDate;
    }
    return _asset_creationDate;
}

@end
