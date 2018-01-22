//
//  Public.swift
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

import UIKit

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height
let appWindow: UIWindow? = { return UIApplication.shared.keyWindow }()


/// 全局提示框
///
/// - Parameter tips: 提示内容
public func EXPTip(tips: String?)
{
    if tips == nil || tips == "" {
        return
    }
    // 提示label
    let tipWidth = screenWidth - 100
    let tipLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tipWidth, height: 35))
    tipLabel.backgroundColor = UIColor.black
    tipLabel.alpha = 0
    
    tipLabel.numberOfLines = 0
    tipLabel.font = UIFont.systemFont(ofSize: 16)
    
    tipLabel.text = tips
    tipLabel.textColor = UIColor.white
    tipLabel.textAlignment = .center
    
    tipLabel.layer.cornerRadius = 6
    tipLabel.clipsToBounds = true
    
    var tipHeight = tips!.heightForString(font: UIFont.systemFont(ofSize: 16), width: tipWidth).height
    tipHeight = (tipHeight >= 35 ? tipHeight+8:35)
    
    tipLabel.frame = CGRect(x: 0, y: 0, width: tipWidth, height: tipHeight)
    tipLabel.center = (appWindow?.center)!
    
    // 将提示框添加到窗口
    appWindow?.addSubview(tipLabel)
    
    UIView.animate(withDuration: 0.6, animations: {
        // 将提示框慢慢显示出来
        tipLabel.alpha = 0.9
        
    }) { (completion) in
        
        UIView.animateKeyframes(withDuration: 0.6, delay: 1, options: [.calculationModeCubicPaced], animations: {
            // 将提示框隐藏
            tipLabel.alpha = 0
            
        }, completion: { (completion) in
            
            // 将提示框从窗口移除
            tipLabel.removeFromSuperview()
        })
        
    }
    
}


// 缩略图片压缩极限(自己画出来)
func useImage(image: UIImage) -> Data? {
    //实现等比例缩放
    let hfactor = image.size.width / screenWidth;
    let vfactor = image.size.height / screenHeight;
    let factor = fmax(hfactor, vfactor);
    //画布大小
    let newWith: CGFloat = image.size.width / factor
    let newHeigth: CGFloat = image.size.height / factor
    let newSize = CGSize(width: newWith, height: newHeigth)
    
    UIGraphicsBeginImageContext(newSize)
    image.draw(in: CGRect(x: 0, y: 0, width: newWith, height: newHeigth))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    //图像压缩
    if newImage != nil {
        let newImageData = UIImageJPEGRepresentation(newImage!, 1)
        return newImageData
    } else {
        return nil
    }
    
}
