//
//  ImageResizer.swift
//  w2p
//
//  Created by vas on 16.02.2021.
//

import UIKit

class ImageResizer {
    
    static func resizeImageToFit(width: CGFloat, image: UIImage) -> UIImage {
        let aspect = image.size.height / image.size.width
        let newWidth = width
        let newHeight = newWidth * aspect
        let newSize = CGSize(width: newWidth, height: newHeight)
        let rect = CGRect(origin: .zero, size: newSize)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image{
            context in
            image.draw(in: rect)
        }
    }
}
