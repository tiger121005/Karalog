//
//  Manager.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/04/30.
//

import Foundation

var manager = Manager.shared


//MARK: Manager

struct Manager {
    static var shared = Manager()
    
    var musicList: [MusicList] = []
    
    var lists: [Lists] = []
        
    var user: User!
}
