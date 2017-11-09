//
//  UIColor+Combine.swift
//  iScales
//
//  Created by Orange on 2017/10/26.
//  Copyright © 2017年 Scott Law. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    func combine(coverColor: UIColor) -> UIColor {
        let c1 = coverColor.rgba()
        let c2 = self.rgba()
        
        let c1r = CGFloat(c1.r)
        let c1g = CGFloat(c1.g)
        let c1b = CGFloat(c1.b)
        
        let c2r = CGFloat(c2.r)
        let c2g = CGFloat(c2.g)
        let c2b = CGFloat(c2.b)
        
        // 前景色叠图公式
        let r = c1r * c1.a + c2r * c2.a * (1 - c1.a)
        let g = c1g * c1.a + c2g * c2.a * (1 - c1.a)
        let b = c1b * c1.a + c2b * c2.a * (1 - c1.a)
        
        // 背景色叠图公式
//        let alpha = 1.0 - (1.0 - c1.a) * ( 1 - c2.a)
//        let R = r / alpha
//        let G = g / alpha
//        let B = b / alpha
        return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
    

    // MARK: - 去亮度型
    /// Darken 变暗  B<=A: C=B; B>=A: C=A
    func combineDarken(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) { return ($0 <= $1) ? $0 : $1 }
    }
    
    /// Multiply 正片叠底 C = A*B
    func combineMultiply(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) { return $0 * $1 }
    }
    
    /// Color Burn 颜色加深 C=1-(1-B)/A
    func combineColorBurn(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) { return 1 - (1 - $0) / $1 }
    }
    
    /// Linear Burn 线性加深 C=A+B-1
    func combineLinearBurn(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) { return ($1 + $0) - 1.0 }
    }
    
    // MARK: - 去暗型
    /// Lighten 变亮   B>=A: C=B; B<=A: C=A
    func combineLighten(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) { return ($0 >= $1) ? $0 : $1 }
    }
    
    /// Screen 滤色 C=1-(1-A)*(1-B), 也可以写成 1-C=(1-A)*(1-B)
    func combineScreen(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) { return 1 - (1 - $1) * (1 - $0) }
    }
    
    /// Linear Dodge 线性减淡 C=A+B
    func combineLinearDodge(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) { return $1 + $0 }
    }
    
    /// Color Dodge 颜色减淡 C=B/(1-A)
    func combineColorDodge(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) { return $0 / (1 - $1) }
    }
    
    
    // MARK: - 溶合型
    /// Overlay 叠加 B<=0.5: C=2*A*B; B>0.5: C=1-2*(1-A)*(1-B)
    func combineOverlay(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) {
            if $0 <= 0.5 { return 2 * $1 * $0 }
            else { return 1 - 2 * (1 - $1) * (1 - $0) }
        }
    }
    
    /// Soft Light 柔光 A<=0.5: C=(2*A-1)*(B-B*B)+B; A>0.5: C=(2*A-1)*(sqrt(B)-B)+B
    func combineSoftLight(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) {
            if $1 <= 0.5 { return (2 * $1 - 1) * ($0 - $0 * $0) + $0 }
            else { return (2 * $1 - 1)*( sqrt($0) - $0) + $0 }
        }
    }
    
    /// Hard Light 强光 A<=0.5: C=2*A*B; A>0.5: C=1-2*(1-A)*(1-B)
    func combineHardLight(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) {
            if $1 <= 0.5 { return 2 * $1 * $0 }
            else { return 1 - 2 * (1 - $1) * (1 - $0) }
        }
    }
    
    /// Vivid Light 亮光 A<=0.5: C=1-(1-B)/2*A; A>0.5: C=B/(2*(1-A))
    func combineVividLight(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) {
            if $1 <= 0.5 { return 1 - (1 - $0) / 2 * $1 }
            else { return $0 / (2 * (1 - $1)) }
        }
    }
    
    /// Linear Light 线性光 C=B+2*A-1
    func combineLinearLight(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) { return $0 + 2 * $1 - 1 }
    }
    
    /// Pin Light 点光
    /// B<2*A-1:     C=2*A-1
    /// 2*A-1<B<2*A: C=B
    /// B>2*A:       C=2*A
    func combinePinLight(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) {
            if $0 <= 2 * $1 - 1 { return 2 * $1 - 1 }
            else if (2 * $1 - 1 < $0) && ($0 < 2 * $1) { return $0}
            else { return 2 * $1 }
        }
    }
    
    /// Hard Mix 实色混合A<1-B: C=0; A>1-B: C=1
    func combineHardMix(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) {
            if $1 <= 1 - $0 { return 0 }
            else { return 1 }
        }
    }
    
    // MARK: - 色差型
    /// Difference 差值 C=|A-B|
    func combineDifference(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) { fabs($1 - $0) }
    }
    
    /// Exclusion 排除 C = A+B-2*A*B
    func combineExclusion(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) { $1 + $0 - 2 * $1 * $0  }
    }
    
    /// 减去 C=A-B
    func combineMinus(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) { $1 - $0 }
    }
    
    /// 划分 C=A/B
    func combineDivision(coverColor: UIColor,alpha: CGFloat = 1.0) -> UIColor {
        return combineProcedure(coverColor: coverColor, alpha: alpha) { $1 / $0  }
    }
    
    func combineProcedure(
        coverColor: UIColor,
        alpha: CGFloat,
        procedureBlock: ((_ baseValue: CGFloat,_ topValue: CGFloat) -> CGFloat)?
        ) -> UIColor {
        let baseCompoment = coverColor.rgba()
        let topCompoment = self.rgba()
        
        // 该层透明度
        let mixAlpha = alpha * topCompoment.a + (1.0 - alpha) * baseCompoment.a
        // RGB 值
        let mixR = procedureBlock?(CGFloat(baseCompoment.r)/255.0, CGFloat(topCompoment.r)/255.0) ?? CGFloat(baseCompoment.r)/255.0
        let mixG = procedureBlock?(CGFloat(baseCompoment.g)/255.0, CGFloat(topCompoment.g)/255.0) ?? CGFloat(baseCompoment.g)/255.0
        let mixB = procedureBlock?(CGFloat(baseCompoment.b)/255.0, CGFloat(topCompoment.b)/255.0) ?? CGFloat(baseCompoment.b)/255.0
        
        return UIColor.init(red: mixR, green: mixG, blue: mixB, alpha: mixAlpha)
    }
}
