//
//  UIFont+Karma.swift
//  Client
//
//  Created by Lilla on 17/11/2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    class func customFont(ofSize fontSize: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        switch weight {
        case .bold:
            return UIFont(name: "ProximaNova-Bold", size: fontSize)!
        case .heavy:
            return UIFont(name: "ProximaNova-Extrabold", size: fontSize)!
        case .regular:
            return UIFont(name: "ProximaNova-Regular", size: fontSize)!
        case .medium:
            return UIFont(name: "ProximaNova-Medium", size: fontSize)!
        case .semibold:
            return UIFont(name: "ProximaNova-SemiBold", size: fontSize)!
        default:
            return UIFont(name: "ProximaNova-Regular", size: fontSize-2)!
        }
    }
    
    class func customFontKG(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "KGSecondChancesSolid", size: fontSize)!
    }
    
    func calculateHeight(text: String, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: self],
                                        context: nil)
        return boundingBox.height
    }
}
