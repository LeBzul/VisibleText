//
//  VisibleTextContainer.swift
//  VisibleTextContainer
//
//  Created by Drouin on 11/06/2019.
//  Copyright © 2019 VersusMind. All rights reserved.
//

import UIKit

class VisibleTextContainer: UIView {
    
    @IBInspectable var darkTextColor = UIColor.darkText
    @IBInspectable var lightTextColor = UIColor.white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func refreshView() {
        self.backgroundColor = UIColor.clear
        layoutIfNeeded()
        for view in subviews {
            switch(view) {
            case is UILabel, is UITextField, is UITextView:
                view.layoutIfNeeded()
                analyseSuperViewColor(view: view)
            default: break
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshView()
    }
    
    func screenShotMethod() -> UIImage? {
        if let layer = UIApplication.shared.keyWindow?.layer {
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
            
            if let screenshot = UIGraphicsGetCurrentContext() {
                layer.render(in: screenshot)
            }
            
            if let screenshot = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                return screenshot
            }
        }
        return nil
    }

    func snapshot(in image: UIImage, rect: CGRect) -> UIImage {
       // let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        let newRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height)
        let size = newRect.size
        
        let origin = CGPoint(x: newRect.minX, y: newRect.minY)
        let scaledRect = CGRect(origin: origin, size: size)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false
        
        return UIGraphicsImageRenderer(bounds: scaledRect, format: format).image { _ in
            image.draw(at: .zero)
        }
    }
    
    private func analyseSuperViewColor(view: UIView) {
        if let image = screenShotMethod() {
            let rect = CGRect(x: self.frame.minX + view.frame.minX, y: self.frame.minY + view.frame.minY, width: view.frame.width, height: view.frame.height)

            let ms = snapshot(in: image, rect: rect)
            var color = darkTextColor
            if ms.isDark {
                color = lightTextColor
            }

            switch(view) {
            case let label as UILabel: label.textColor = color
            case let textfield as UITextField: textfield.textColor = color
            case let textview as UITextView: textview.textColor = color
            default: break
            }
        }
    }
}


private extension CGImage {
    var isDark: Bool {
        get {
            guard let imageData = self.dataProvider?.data else { return false }
            guard let ptr = CFDataGetBytePtr(imageData) else { return false }
            let length = CFDataGetLength(imageData)
            let threshold = Int(Double(self.width * self.height) * 0.45)
            var darkPixels = 0
            for i in stride(from: 0, to: length, by: 4) {
                let r = ptr[i]
                let g = ptr[i + 1]
                let b = ptr[i + 2]
                let luminance = (0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b))
                if luminance < 150 {
                    darkPixels += 1
                    if darkPixels > threshold {
                        return true
                    }
                }
            }
            return false
        }
    }
}

private extension UIImage {
    var isDark: Bool {
        get {
            return self.cgImage?.isDark ?? false
        }
    }
}
