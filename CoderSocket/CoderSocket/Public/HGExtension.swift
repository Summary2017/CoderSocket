//
//  HGExtension.swift
//  CoderSocket
//
//  Created by  ZhuHong on 2018/1/22.
//  Copyright © 2018年 CoderHG. All rights reserved.
//

/** 扩展 **/

import UIKit


// MARK: - String
extension String {
    
    // 宽度未知，计算String文字的Size
    func widthForString(font:UIFont,height:CGFloat) ->CGSize {
        
        let stringRect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height), options: [.usesFontLeading], attributes: [NSAttributedStringKey.font:font], context: nil)
        
        return stringRect.size
    }
    
    // 高度未知，计算String文字的Size
    func heightForString(font:UIFont,width:CGFloat) ->CGSize {
        
        let stringRect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font:font], context: nil)
        
        return stringRect.size
    }
    
    // 截取一段字符串  eg: "hello world"[2...5] = "llo "
    subscript (r: ClosedRange<Int>) -> String? {
        
        if r.upperBound >= self.count {
            return nil
        } else  {
            let stringRange = Range<String.Index>(NSMakeRange(r.lowerBound, r.upperBound-r.lowerBound + 1), in: self)
            
            return self[stringRange!].description
        }
        
    }
}

// MARK: - Dictionary
extension Dictionary {
    
    // dictionary不可变时，添加新值
    func addNewValue(key: String, value: Any) ->Dictionary<String, Any>{
        
        var newValue = self as! Dictionary<String, Any>
        newValue.updateValue(value, forKey: key)
        return newValue
    }
    
}

// MARK: - UIColor
extension UIColor {
    
    /// 设置颜色
    class func colorWithRGB(red:CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> UIColor {
        
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
}

// MARK: - UIFont
extension UIFont {
    
    /// 设置字体大小
    class func fontWithSize(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: size, weight: weight)
        } else {
            // Fallback on earlier versions
            return UIFont.systemFont(ofSize: size)
        }
        
    }
}

// MARK: - UIImage
extension UIImage {
    
    // 画虚线分割线
    func imageWithDottedLine(lineSize: CGSize, spacing: CGFloat) -> UIImage? {
        
        // 开始画线
        UIGraphicsBeginImageContext(lineSize)
        self.draw(in: CGRect(origin: .zero, size: lineSize), blendMode: .destinationIn, alpha: 1)
        
        let lineContext = UIGraphicsGetCurrentContext()
        lineContext?.setLineWidth(1.5)
        lineContext?.setStrokeColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1)
        lineContext?.setLineDash(phase: 0, lengths: [spacing,1])
        lineContext?.move(to: .zero)
        lineContext?.addLine(to: CGPoint(x: lineSize.width, y: 0))
        lineContext?.strokePath()
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

// MARK: - UIView
extension UIView {
    
    func maxX() -> CGFloat {
        return self.frame.maxX
    }
    
    func maxY() -> CGFloat {
        return self.frame.maxY
    }
    
    func X() -> CGFloat {
        return self.frame.origin.x
    }
    
    func Y() -> CGFloat {
        return self.frame.origin.y
    }
    
    func width() -> CGFloat {
        return self.frame.width
    }
    
    func height() -> CGFloat {
        return self.frame.height
    }
}

