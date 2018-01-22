//
//  PhotoAssets.swift
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

/** 获取相册图片 **/

import UIKit
import Photos

class PhotoAssets: NSObject {
    /// 获取所有相册里的资源
    ///
    /// - Parameters:
    ///   - targetSize: 目标尺寸
    @objc class func getAllOriginalImages(targetThumbSize: CGSize, isLoadVideo: Bool, loadSucess:@escaping (_ assetModels: NSArray) -> Void){
        
        // 相册所有图片和视频模型
        let assetsModels: NSMutableArray = []
        
        // 获取所有相册
        var fetchResults: PHFetchResult<PHAssetCollection>
        if isLoadVideo {
            fetchResults = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: nil)
        } else  {
            fetchResults = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        }
        
        print("资源数量", fetchResults.count)
        
        // 队列组
        let assetsGroup = DispatchGroup()
        // 遍历所有相册
        for i in 0..<fetchResults.count {
            
            let assets = PHAsset.fetchAssets(in: fetchResults[i], options: nil)
            
            // 遍历一个相册的所有资源
            for j in 0..<assets.count {
                
                // 获取一个资源模型
                let photoModel = PhotoAssetsModel.photo(withAssets: assets[j])
                
                if isLoadVideo {
                    
                    // 只加载视频
                    if assets[j].mediaType == .video {
                        
                        assetsGroup.enter()
                        PHImageManager.default().requestPlayerItem(forVideo: assets[j], options: nil, resultHandler: { (item, videoInfoDic) in
                            
                            DispatchQueue.main.async {
                                if let info = videoInfoDic as? Dictionary<String, Any> {
                                    
                                    // 视频名
                                    if let filePath = info["PHImageFileSandboxExtensionTokenKey"] as? String {
                                        photoModel!.fileName = filePath.components(separatedBy: "/").last
                                    }
                                    
                                    // 视频路径以及视频大小
                                    if let infoPath = info["PHImageFileSandboxExtensionTokenKey"] as? String {
                                        if let filePath = infoPath.components(separatedBy: ";").last {
                                            
                                            photoModel!.filePath = filePath
                                            if let fileData = NSData(contentsOfFile: filePath) {
                                                photoModel!.fileLength = NSInteger(fileData.length)
                                                print("资源大小",fileData.length)
                                                
                                            }
                                        }
                                    }
                                    
                                    assetsModels.add(photoModel!)
                                    assetsGroup.leave()
                                }
                            }
                            
                        })
                    }
                    
                } else {
                    
                    // 只加载图片数据
                    assetsGroup.enter()
                    PhotoAssets.loadOrigationPhoto(assetModel: photoModel!, loadSucess: {
                        assetsModels.add(photoModel!)
                        assetsGroup.leave()
                    })
                }
            }
        }
        
        assetsGroup.notify(queue: DispatchQueue.main) {
            loadSucess(assetsModels)
        }
        
    }
    
    /// 通过EUCPhotoAssetsModel模型获取真实图片 === UIImage
    ///
    /// - Parameters:
    ///   - assetModel: 资源模型
    ///   - loadSucess: 加载成功回调
    @objc class func loadOrigationPhoto(assetModel: PhotoAssetsModel, loadSucess:@escaping ()->Void) {
        
        // 图片资源
        let photoAsset = (assetModel.passet)!
        let assetSize = CGSize(width: 80, height: 80)
        
        // 获取真实图片
        PHImageManager.default().requestImage(for: photoAsset, targetSize: assetSize, contentMode: .aspectFit, options: nil) { (image, imageDic) in
            
            DispatchQueue.main.async {
                assetModel.origImage = image
                loadSucess()
            }
        }
        
    }
    
    /// 通过EUCPhotoAssetsModel模型获取数据  === Data
    ///
    /// - Parameters:
    ///   - assetModel: 资源模型
    ///   - loadSucess: 加载成功回调
    @objc class func loadOrigationPhotoData(assetModel: PhotoAssetsModel, loadSucess:@escaping ()->Void) {
        
        // 资源
        let photoAsset = (assetModel.passet)!
        
        PHImageManager.default().requestImageData(for: photoAsset, options: nil) { (data, dataStr, imageOrein, dataDic) in
            
            DispatchQueue.main.async {
                
                if let info = dataDic as? Dictionary<String, Any> {
                    if let filePath = (info["PHImageFileURLKey"] as? URL) {
                        assetModel.fileName = filePath.lastPathComponent
                    }
                }
                if data != nil {
                    assetModel.fileData = data!
                    let fileData = data! as NSData
                    assetModel.fileLength = fileData.length
                }
                loadSucess()
            }
        }
        
    }
    
    
    /// 通过EUCPhotoAssetsModel模型加载视频资源 ===
    ///
    /// - Parameters:
    ///   - assetModel: 资源模型
    ///   - loadSucess: 加载成功回调
    @objc class func loadOrigationPlayItem(assetModel: PhotoAssetsModel, loadSucess:@escaping()-> Void ) {
        
        // 视频资源
        let videoAsset = (assetModel.passet)!
        
        // 获取视频资源
        PHImageManager.default().requestAVAsset(forVideo: videoAsset, options: nil) { (avAsset, audioMix, avAssetDic) in
            
            DispatchQueue.main.async {
                if avAsset != nil {
                    assetModel.avasset = avAsset!
                    if let url = (avAsset as? AVURLAsset)?.url {
                        assetModel.fileData = try? Data(contentsOf: url)
                        assetModel.filePath = url.path
                        assetModel.fileUrl = url as! URL
                    }
                }
                if audioMix != nil {
                    assetModel.audioAsset = audioMix!
                }
//                if let info = avAssetDic as? Dictionary<String, Any> {
//
//                    if let filePathValue = info["PHImageFileSandboxExtensionTokenKey"] as? String {
//
//                        if let filePath = filePathValue.components(separatedBy: ";").last {
//
//                            assetModel.filePath = filePat
//                        }
//                    }
//                }
                loadSucess()
            }
        }
    }
}
