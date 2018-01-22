//
//  PhotoCell.swift
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    // 插座变量
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    
    var photoModel: PhotoAssetsModel! {
        didSet {
            self.photoImageView.image = photoModel.origImage
            if photoModel.selected {
                self.selectButton.isHidden = false
            } else {
                self.selectButton.isHidden = true
            }
        }
    }

}
