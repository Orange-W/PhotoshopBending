# PhotoshopBending
Photoshop 图层混合效果
```
//
//  UIColor+Combine.swift
//  iScales
//
//  Created by OrangeEvan on 2017/10/26.
//  Copyright © 2017年 NetEase. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    // MARK: - 常用叠图
    // Alpha Blending 前景色叠图
    func blendAlpha(coverColor: UIColor) -> UIColor {
        let c1 = coverColor.rgbaTuple()
        let c2 = self.rgbaTuple()
        
        let c1r = CGFloat(c1.r)
        let c1g = CGFloat(c1.g)
        let c1b = CGFloat(c1.b)
        
        let c2r = CGFloat(c2.r)
        let c2g = CGFloat(c2.g)
        let c2b = CGFloat(c2.b)
        
        // 前景色叠图公式
        let r = c1r * c1.a + c2r  * (1 - c1.a)
        let g = c1g * c1.a + c2g  * (1 - c1.a)
        let b = c1b * c1.a + c2b  * (1 - c1.a)
      
        return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
    
    
    // MARK: - 去亮度型
    /// Darken 变暗  B<=A: C=B; B>=A: C=A
    func blendDarken(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) { return ($0 <= $1) ? $0 : $1 }
    }
    
    /// Multiply 正片叠底 C = A*B
    func blendMultiply(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) { return $0 * $1 }
    }
    
    /// Color Burn 颜色加深 C=1-(1-B)/A
    func blendColorBurn(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) { return 1 - (1 - $0) / $1 }
    }
    
    /// Linear Burn 线性加深 C=A+B-1
    func blendLinearBurn(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) { return ($1 + $0) - 1.0 }
    }
    
    // MARK: - 去暗型
    /// Lighten 变亮   B>=A: C=B; B<=A: C=A
    func blendLighten(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) { return ($0 >= $1) ? $0 : $1 }
    }
    
    /// Screen 滤色 C=1-(1-A)*(1-B), 也可以写成 1-C=(1-A)*(1-B)
    func blendScreen(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) { return 1 - (1 - $1) * (1 - $0) }
    }
    
    /// Color Dodge 颜色减淡 C=B/(1-A)
    func blendColorDodge(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) {
            if $1 >= 1.0 { return $1 }
            else { return min(1.0, $0 / (1 - $1)) }
        }
    }
    
    /// Linear Dodge 线性减淡 C=A+B
    func blendLinearDodge(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) { return min(1, $1 + $0) }
    }
    
    // MARK: - 溶合型
    /// Overlay 叠加 B<=0.5: C=2*A*B; B>0.5: C=1-2*(1-A)*(1-B)
    func blendOverlay(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) {
            if $0 <= 0.5 { return 2 * $1 * $0 }
            else { return 1 - 2 * (1 - $1) * (1 - $0) }
        }
    }
    
    /// Soft Light 柔光 A<=0.5: C=(2*A-1)*(B-B*B)+B; A>0.5: C=(2*A-1)*(sqrt(B)-B)+B
    func blendSoftLight(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) {
            if $1 <= 0.5 { return (2 * $1 - 1) * ($0 - $0 * $0) + $0 }
            else { return (2 * $1 - 1)*( sqrt($0) - $0) + $0 }
        }
    }
    
    /// Hard Light 强光 A<=0.5: C=2*A*B; A>0.5: C=1-2*(1-A)*(1-B)
    func blendHardLight(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) {
            if $1 <= 0.5 { return 2 * $1 * $0 }
            else { return 1 - 2 * (1 - $1) * (1 - $0) }
        }
    }
    
    /// Vivid Light 亮光 A<=0.5: C=1-(1-B)/(2*A); A>0.5: C=B/(2*(1-A))
    func blendVividLight(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) {
            if $1 <= 0.5 { return self.fitIn((1 - (1 - $0) / (2 * $1)), ceil: 1.0) }
            else { return self.fitIn($0 / (2 * (1 - $1)), ceil: 1.0) }
        }
    }
    
    /// Linear Light 线性光 C=B+2*A-1
    func blendLinearLight(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) { return self.fitIn($0 + 2 * $1 - 1, ceil: 1.0) }
    }
    
    /// Pin Light 点光
    /// B<2*A-1:     C=2*A-1
    /// 2*A-1<B<2*A: C=B
    /// B>2*A:       C=2*A
    func blendPinLight(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) {
            if $0 <= 2 * $1 - 1 { return 2 * $1 - 1 }
            else if (2 * $1 - 1 < $0) && ($0 < 2 * $1) { return $0}
            else { return 2 * $1 }
        }
    }
    
    /// Hard Mix 实色混合A<1-B: C=0; A>1-B: C=1
    func blendHardMix(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) {
            if $1 <= 1 - $0 { return 0 }
            else { return 1 }
        }
    }
    
    // MARK: - 色差型
    /// Difference 差值 C=|A-B|
    func blendDifference(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) { fabs($1 - $0) }
    }
    
    /// Exclusion 排除 C = A+B-2*A*B
    func blendExclusion(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) { $1 + $0 - 2 * $1 * $0  }
    }
    
    /// 减去 C=A-B
    func blendMinus(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) { $1 - $0 }
    }
    
    /// 划分 C=A/B
    func blendDivision(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return blendProcedure(coverColor: coverColor, alpha: alpha) {
            if $0 == 0{
                return 1.0
            }else {
                return self.fitIn($1 / $0, ceil: 1.0)
            }
        }
    }
    
    // MARK: 处理函数
    func blendProcedure(
        coverColor: UIColor,
        alpha: CGFloat,
        procedureBlock: ((_ baseValue: CGFloat,_ topValue: CGFloat) -> CGFloat)?
        ) -> UIColor {
        let baseCompoment = self.rgbaTuple()
        let topCompoment = coverColor.rgbaTuple()
        
        // 该层透明度
        let mixAlpha = alpha * topCompoment.a + (1.0 - alpha) * baseCompoment.a
        
        // RGB 值
        let mixR = procedureBlock?(
            baseCompoment.r / 255.0,
            topCompoment.r / 255.0)
            ?? (baseCompoment.r) / 255.0
        
        let mixG = procedureBlock?(
            baseCompoment.g / 255.0,
            topCompoment.g / 255.0)
            ?? (baseCompoment.g) / 255.0
        
        let mixB = procedureBlock?(
            baseCompoment.b / 255.0,
            topCompoment.b / 255.0)
            ?? baseCompoment.b / 255.0
        
        
        return UIColor.init(red:   fitIn(mixR),
                            green: fitIn(mixG),
                            blue:  fitIn(mixB),
                            alpha: mixAlpha)
    }
    
    // 防止越界
    func fitIn(_ value: CGFloat, ceil: CGFloat = 255) -> CGFloat { return max(min(value,ceil),0) }
    func fitIn(_ value: Double, ceil: CGFloat = 255) -> CGFloat { return fitIn(CGFloat(value), ceil: ceil) }
    
    // 返回 RBGA
    func rgbaTuple() -> (r: CGFloat, g: CGFloat, b: CGFloat,a: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        r = r * 255
        g = g * 255
        b = b * 255
        
        return ((r),(g),(b),a)
    }
}
```
