//
//  VMFloatLabelTextField.swift
//  VMFloatLabel
//
//  Created by Jimmy Jose on 08/12/14.
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit

class VMFloatLabelTextField: UITextField {
    
    var floatingLabel = UILabel()
    
    var floatingLabelYPadding:CGFloat = 0.0
    
    var placeholderYPadding:CGFloat = 0.0
    
    var floatingLabelFont:UIFont?
    
    var floatingLabelTextColor = UIColor.gray
    
    var floatingLabelActiveTextColor:UIColor?
    
    var animateEvenIfNotFirstResponder:NSInteger = 0
    
    var floatingLabelShowAnimationDuration = 0.3
    
    var floatingLabelHideAnimationDuration = 0.3
    
    
    fileprivate  convenience init(){
        
        self.init()
        commonInit()
        
    }
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    
    fileprivate func commonInit(){
        
        self.floatingLabel = UILabel()
        self.floatingLabel.alpha = 0.0
        
        self.addSubview(self.floatingLabel)
        
        self.floatingLabelFont = UIFont.boldSystemFont(ofSize: 12.0)
        self.floatingLabel.font = self.floatingLabelFont
        self.floatingLabel.textColor = self.floatingLabelTextColor
        
        
        self.floatingLabelTextColor = UIColor.gray
        self.floatingLabel.textColor = self.floatingLabelTextColor
        self.floatingLabelActiveTextColor = self.tintColor
        self.animateEvenIfNotFirstResponder = 0
        
        setFloatingLabelText(self.placeholder!)
        
    }
    
    func setFloatingLabelText(_ text:String){
        
        self.floatingLabel.text = text
        self.setNeedsLayout()
        
    }
    
    
    func labelActiveColor() -> UIColor {
        
        if(self.floatingLabelActiveTextColor != nil){
            
            return self.floatingLabelActiveTextColor!
            
        }else {
            
            
            let window = UIApplication.shared.keyWindow
            if((window) != nil){
                let color = window?.tintColor
                if((color) != nil){
                    return color!
                    
                }
            }
        }
        return UIColor(red:0.04, green:0.82, blue:0.95, alpha:1.0)
    }
    
    func FloatingLabelFont(_ floatingLabelFont:UIFont){
        
        self.floatingLabelFont = floatingLabelFont
        //self.floatingLabel.font = (floatingLabelFont ? floatingLabelFont : UIFont.boldSystemFontOfSize(12.0))
        self.placeholder = self.placeholder
        
    }
    
    func showFloatingLabel(_ animated:Bool){
        
        if (animated || self.animateEvenIfNotFirstResponder != 0){
            
            UIView.animate(withDuration: self.floatingLabelShowAnimationDuration, delay: 0.0, options:[.beginFromCurrentState, .curveEaseIn], animations: { () -> Void in
                
                self.floatingLabel.alpha = 1.0
                self.floatingLabel.frame = CGRect(x: self.floatingLabel.frame.origin.x, y: self.floatingLabelYPadding, width: self.floatingLabel.frame.width, height: self.floatingLabel.frame.height)
                   
                
                
                }, completion:nil)
            
        }else {
            
            self.floatingLabel.alpha = 1.0
            self.floatingLabel.frame = CGRect(x: self.floatingLabel.frame.origin.x, y: self.floatingLabelYPadding, width: self.floatingLabel.frame.width, height: self.floatingLabel.frame.height)
            
        }
        
    }
    
    
    func hideFloatingLabel(_ animated:Bool){
        
        if (animated || self.animateEvenIfNotFirstResponder != 0){
            
            UIView.animate(withDuration: self.floatingLabelHideAnimationDuration, delay: 0.0, options: [.beginFromCurrentState, .curveEaseIn], animations: { () -> Void in
                
                self.floatingLabel.alpha = 0.0
                self.floatingLabel.frame = CGRect(origin: CGPoint(x: self.floatingLabel.frame.origin.x,y :self.floatingLabel.font.lineHeight + self.floatingLabelYPadding), size: CGSize(width: self.floatingLabel.frame.width, height: self.floatingLabel.frame.height))
                
                
                }, completion:nil)
            
        }else {
            
            self.floatingLabel.alpha = 0.0
            self.floatingLabel.frame = CGRect(x: self.floatingLabel.frame.origin.x, y: self.floatingLabel.font.lineHeight + self.floatingLabelYPadding, width: self.floatingLabel.frame.width, height: self.floatingLabel.frame.height)
            
        }
        
    }
    
    
    func setLabelOriginForTextAlignment(){
        
        let textRect:CGRect = self.textRect(forBounds: self.bounds)
        var originX = textRect.origin.x
        
        if (self.textAlignment == NSTextAlignment.center) {
            originX = textRect.origin.x + (textRect.size.width/2) - (self.floatingLabel.frame.size.width/2)
        }
        else if (self.textAlignment == NSTextAlignment.right) {
            originX = textRect.origin.x + textRect.size.width - self.floatingLabel.frame.size.width
        } else if (self.textAlignment == NSTextAlignment.natural) {
            
            /*
            var baseDirection:JVTextDirection = self.floatingLabel.text!.getBaseDirection()
            if (baseDirection == JVTextDirection.JVTextDirectionRightToLeft) {
            originX = textRect.origin.x + textRect.size.width - self.floatingLabel.frame.size.width
            }*/
        }
        
        self.floatingLabel.frame = CGRect(x: originX, y: self.floatingLabel.frame.origin.y,
            width: self.floatingLabel.frame.size.width, height: self.floatingLabel.frame.size.height)
        
    }
    override func textRect(forBounds bounds:CGRect) -> CGRect {
        var rect:CGRect = super.textRect(forBounds: bounds)
        
        let text = self.text!
        
        if (text.characters.count > 0) {
            
            var topInset:CGFloat = CGFloat(ceilf(Float(self.floatingLabel.font.lineHeight + self.placeholderYPadding)))
            topInset = min(topInset, maxTopInset())
            rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(topInset, 0.0, 0.0, 0.0))
            
            
        }
        
        return rect.integral
        
    }
    
    func Placeholder(_ placeholder:NSString){
        
        super.placeholder = placeholder as String
        self.floatingLabel.text = placeholder as String
        self.floatingLabel.sizeToFit()
        
    }
    
    
    func AttributedPlaceholder(_ attributedPlaceholder:NSAttributedString){
        super.placeholder = placeholder
        self.floatingLabel.text = attributedPlaceholder.string
        self.floatingLabel.sizeToFit()
        
    }
    
    
    func setAttributedPlaceholder(_ placeholder:NSAttributedString, floatingTitle:NSString){
        super.attributedPlaceholder = placeholder
        self.floatingLabel.text = floatingTitle as String
        self.floatingLabel.sizeToFit()
        
    }
    
    
    override func
        editingRect(forBounds bounds:CGRect) -> CGRect {
        
        var rect:CGRect = super.editingRect(forBounds: bounds)
        
        let text = self.text!
        
        if (text.characters.count > 0) {
            var topInset:CGFloat = CGFloat(ceilf(Float (self.floatingLabel.font.lineHeight + self.placeholderYPadding)))
            topInset = min(topInset, maxTopInset())
            rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(topInset, 0.0, 0.0, 0.0))
            
        }
        
        return rect.integral
        
    }
    
    override func clearButtonRect(forBounds bounds:CGRect) -> CGRect {
        
        var rect:CGRect = super.clearButtonRect(forBounds: bounds)
        
        let text = self.text!
        
        if (text.characters.count > 0) {
            
            var topInset:CGFloat = CGFloat(ceilf(Float (self.floatingLabel.font.lineHeight + self.placeholderYPadding)))
            topInset = min(topInset, maxTopInset())
            rect = CGRect(x: rect.origin.x, y: rect.origin.y + topInset / 2.0, width: rect.size.width, height: rect.size.height)
            
        }
        
        
        return rect.integral
        
    }
    
    func maxTopInset() -> CGFloat {
        
        let initialValue:CGFloat = 0.0
        return max(initialValue, CGFloat(floorf(Float (self.bounds.size.height - self.font!.lineHeight - 4.0))))
        
    }
    
    
    func TextAlignment(_ textAlignment:NSTextAlignment){
        
        super.textAlignment = textAlignment
        self.setNeedsLayout()
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        setLabelOriginForTextAlignment()
        
        if((self.floatingLabelFont) != nil){
            
            self.floatingLabel.font = self.floatingLabelFont
            
        }
        
        self.floatingLabel.sizeToFit()
        
        let firstResponder:Bool = self.isFirstResponder
        
        let text = self.text!
        
        if(firstResponder && text.characters.count > 0 ){
            
            self.floatingLabel.textColor = self.labelActiveColor()
            
        }else {
            self.floatingLabel.textColor = self.floatingLabelTextColor
        }
        
        
        if (text.characters.count == 0) {
            hideFloatingLabel(firstResponder)
        }
        else {
            
            showFloatingLabel(firstResponder)
        }
        
        
    }
    
    
}
