//
//  ImageBlurer.swift
//  w2p
//
//  Created by vas on 19.02.2021.
//

import CoreImage
import UIKit

class ImageBlurrer{
    
    func blurImage(with sourceImage: UIImage, radius: CGFloat) -> UIImage {
        let context = CIContext(options: nil)
        let inputImage = CIImage(cgImage: sourceImage.cgImage!)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(radius, forKey: "inputRadius")
        let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage

        let cgImage = context.createCGImage(result ?? CIImage(), from: inputImage.extent.inset(by: UIEdgeInsets(top: -3*radius, left: -3*radius, bottom: -3*radius, right: -3*radius)))
        let retVal = UIImage(cgImage: cgImage!)
        return retVal
    }
}

