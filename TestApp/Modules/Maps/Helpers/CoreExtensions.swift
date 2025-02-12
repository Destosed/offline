//
//  CoreExtensions.swift
//  TestApp
//
//  Created by Никита Лужбин on 10.01.2025.
//

import UIKit

extension UIImage {
    
    func scaled(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage ?? self
    }
}
