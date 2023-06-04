//
//  Manager.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/04/30.
//

import Foundation

struct Manager {
    static var shared = Manager()
    
    var musicList: [MusicList] = []
    
    var lists: [Lists] = []
    
    var listOrder: [String] = []
    
    var goodList: [String] = []
}
