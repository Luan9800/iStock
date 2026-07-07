//
//  ImageCompressor.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

enum ImageCompressor {
    static func compressJPEG(_ data: Data, quality: CGFloat = 0.8) -> Data? {
        #if os(macOS)
        guard let image = NSImage(data: data),
              let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff) else { return nil }
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: quality])
        #else
        guard let image = UIImage(data: data) else { return nil }
        return image.jpegData(compressionQuality: quality)
        #endif
    }
}
