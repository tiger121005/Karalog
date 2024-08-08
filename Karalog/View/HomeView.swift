//
//  ContentView.swift
//  KaralogSwiftUI
//
//  Created by TAIGA ITO on 2024/07/25.
//

import SwiftUI

struct HomeView: View {

    var musicList: [Music] = [
        Music(
            musicName: "ケセラセラ", artistName: "ミセス",
            musicImage:
                "https://ogre.natalie.mu/media/news/music/2023/0417/mrsgreenapple_jkt202304.jpg?imwidth=750&imdensity=1",
            favorite: false, lists: [], data: [MusicData(time: "2024年10月12日", score: 83.829, key: 2, model: "DAM", comment: "hello")], id: "bvladjkbv"),
        Music(
            musicName: "aldbc", artistName: "hlfhfoa", musicImage: "aia", favorite: false,
            lists: [],
            data: [MusicData(time: "2024年3月13日", score: 83.749, key: 2, model: "JOYSOUND", comment: "vaiuvaisjdn laiuebfv;kjsandvinad")], id: "vhla"),
    ]

    @State private var navigationPath: NavigationPath = .init()
    @State private var searchWord: String = ""
    
    var width = UIScreen.main.bounds.width

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextField("リストを検索", text: $searchWord)
                    .textFieldStyle(.search)
                    .foregroundColor(.black)
                    .background(Color(uiColor: .baseColor))
                    .tint(.black)
                ScrollView {
                    VStack {
                        ForEach(musicList) { music in
                            NavigationLink(destination: MusicDetailView(navigationPath: $navigationPath, datas: music.data, musicName: music.musicName, musicImage: music.musicImage)) {
                                HomeCell(
                                    musicName: music.musicName, artistName: music.artistName,
                                    musicImage: music.musicImage, favorite: music.favorite, data: music.data
                                )
                            }
                            .buttonStyle(HomeCellStyle())
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        
                    }
                    .padding()
                    
                }
                .background(Color(uiColor: .baseColor))
                .navigationTitle("HOME")
                .navigationBarTitleDisplayMode(.automatic)
                .navigationBarItems(trailing: HStack {
                    NavigationLink(destination: SearchMusicView(navigationPath: $navigationPath)) {
                        Text("+")
                            .foregroundColor(.black)
                            .font(.largeTitle)
                    }
                    
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.black)
                            .bold()
                    })
                })
            }
            .toolbarBackground(Color(uiColor: .imageColor), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    enum pathManager: String {
        case detail
    }
}

#Preview {
    HomeView()
}
