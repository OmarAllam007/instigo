//
//  Extensions.swift
//  instigo
//
//  Created by Omar Khaled on 14/04/2022.
//

import Foundation
import UIKit


extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor{
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIView {
     func anchor(top:NSLayoutYAxisAnchor?, leading:NSLayoutXAxisAnchor?,
                       trailing:NSLayoutXAxisAnchor?, bottom:NSLayoutYAxisAnchor?,
                       paddingTop:CGFloat,paddingLeft:CGFloat,paddingRight:CGFloat,paddingBottom:CGFloat,
                       height:CGFloat,width:CGFloat,centerX:Bool = false){
         
         translatesAutoresizingMaskIntoConstraints = false
         
        if let top = top {
            self.topAnchor.constraint(equalTo: top,constant: paddingTop).isActive = true
        }
         
         if let leading = leading {
             self.leadingAnchor.constraint(equalTo: leading,constant: paddingLeft).isActive = true
         }
         
         if let trailing = trailing {
             self.trailingAnchor.constraint(equalTo: trailing,constant: -paddingRight).isActive = true
         }
         
         if let bottom = bottom {
             self.bottomAnchor.constraint(equalTo: bottom,constant: -paddingBottom).isActive = true
         }
         
         
         if centerX {
             self.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
         }
         
         if height != 0 {
             self.heightAnchor.constraint(equalToConstant: height).isActive = true
         }
         
         if width != 0 {
             self.widthAnchor.constraint(equalToConstant: width).isActive = true
         }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
