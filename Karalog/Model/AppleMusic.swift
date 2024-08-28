//
//  ApleMusic.swift
//  KaralogSwiftUI
//
//  Created by TAIGA ITO on 2024/07/29.
//

import MusicKit
import Foundation
import UIKit

class AppleMusic {
    
    static let shared = AppleMusic()
    
    func getMusic(word: String) async -> [Song] {
        do {
            
            var request = MusicCatalogSearchRequest(term: word, types: [Song.self])
            request.limit = 10
            let response = try await request.response()
            let songs = response.songs
            
            print(songs)
            return Array(songs)
            
        } catch {
            print("Error get Music from AppleMusic: \(error)")
            return []
        }
    }
}
