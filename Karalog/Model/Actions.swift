//
//  Actions.swift
//  KaralogSwiftUI
//
//  Created by TAIGA ITO on 2024/07/25.
//

import Foundation
import UIKit

extension UIImage {

    static func fromUrl(url: URL?) async -> UIImage {
        do {
            guard let url else {
                print("URL is nil")
                return .noImage.withTintColor(.white)
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                print("Cannot get image from data")
                return .noImage.withTintColor(.white)
            }
            print("Success get image")
            return image
        } catch {
            print("Error get image data")
            return .noImage.withTintColor(.white)
        }

    }
    
    static func fromString(string: String) async -> UIImage {
        guard let imageUrl = URL(string: string) else {
            print("Cannot get URL of image")
            return .noImage.withTintColor(.white)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: imageUrl)
            guard let image = UIImage(data: data) else {
                print("Cannot get image from data")
                return .noImage.withTintColor(.white)
            }
            print("Success get image")
            return image
        } catch {
            print("Error get image data")
            return .noImage.withTintColor(.white)
        }
    }
}

extension Array {
    func groupByTwo() -> [Array] {
        var original = self
        var result: [Array] = []
        
        while original.count != 0 {
            result.append(Array(original.prefix(2)))
            guard original.count != 1 else {
                original = []
                break
            }
            original.removeFirst(2)
        }
        return result
    }
}

extension Array where Element == MusicData {
    func bestScore() -> Double {
        let scores = self.map { $0.score }
        return scores.max() ?? 0.0
    }
}


