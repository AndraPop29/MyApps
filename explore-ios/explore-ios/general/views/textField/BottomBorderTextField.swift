//
//  BottomBorderTextField.swift
//  explore-ios
//
//  Created by Andra on 06/11/2017.
//  Copyright © 2017 andrapop. All rights reserved.
//

import Foundation

import UIKit

@IBDesignable
class BottomBorderTextField: UITextField {
    
    @IBInspectable var paddingLeft: CGFloat = 0
    @IBInspectable var paddingRight: CGFloat = 0
    @IBInspectable var paddingTop : CGFloat = 0
    @IBInspectable var paddingBottom : CGFloat = 5
    
    let border = CALayer()
    
    var borderColor : UIColor = .black{
        didSet{
            setBorderColor()
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + paddingLeft, y: bounds.origin.y + paddingTop, width: bounds.size.width - paddingLeft - paddingRight, height: bounds.size.height-paddingTop-paddingBottom)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    private func setBorder(){
        let width = CGFloat(1.0)
        setBorderColor()
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    private func setBorderColor(){
        border.borderColor = borderColor.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setBorder()
    }
    
    
}
