//
//  CustomCIFilter.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/09/28.
//

import Foundation
import CoreImage

open class CustomCIFilter: CIFilter {

    public var inputImage: CIImage?

    open override func setDefaults() {
        self.inputImage = nil
    }

    override open var outputImage: CIImage? {

        return self.inputImage

    }


}
