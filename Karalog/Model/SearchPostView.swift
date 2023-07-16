//
//  SearchPostView.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/07/10.
//

import SwiftUI

struct SearchPostView: View {
    @State var isShow = false
    var body: some View {
        VStack {
            if isShow {
                Rectangle()
                    .frame(width: 200, height: 200)
                    .transition(.move(edge: .trailing))
            }
                
            Button("Switch") {
                withAnimation {
                    self.isShow.toggle()
                }
            }
        }
    }
}
