//
//  SearchMusicView.swift
//  KaralogSwiftUI
//
//  Created by TAIGA ITO on 2024/07/29.
//

import SwiftUI
import MusicKit

struct SearchMusicView: View {
        
    @Binding var navigationPath: NavigationPath
    
    @State var searchText: String = ""
    
    var width = UIScreen.main.bounds.width
    
    @State var datas: [Song] = []
    
    let colums: [GridItem] = Array(repeating: .init(), count: 2)
    
    var body: some View {
        VStack(spacing: 0) {
            TextField("曲を検索", text: $searchText)
                .textFieldStyle(.search)
                .foregroundColor(.black)
                .background(Color(uiColor: .baseColor))
                .tint(.black)
                .onChange(of: searchText) {
                    Task {
                        self.datas = await AppleMusic.shared.getMusic(word: searchText)
                        
                    }
                }
            ScrollView {
                LazyVGrid(columns: colums, content: {
                    ForEach(datas) { data in
                        MusicCell(imageURL: data.artwork?.url(width: 540, height: 540), music: data.title, artist: data.artistName)
                    }
                    .task {
                        print("datas", datas)
                    }
                })
            }
            .frame(maxHeight: .infinity)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(uiColor: .imageColor), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .background(Color(uiColor: .baseColor))
    }
}

#Preview {
    SearchMusicView(navigationPath: .constant(NavigationPath.init()))
}
