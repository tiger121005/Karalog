//
//  MusicDetailView.swift
//  KaralogSwiftUI
//
//  Created by TAIGA ITO on 2024/07/25.
//

import SwiftUI

struct MusicDetailView: View {

    @Binding var navigationPath: NavigationPath
    
    @State var datas: [MusicData]
    @State var musicName: String
    @State var musicImage: String
    @State var image: UIImage = UIImage.noImage
    
    let width = UIScreen.main.bounds.width

    var body: some View {
        VStack {
            ScrollView {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: width*0.6)
                        .clipShape(Rectangle())
                        .task {
                            image = await UIImage.fromString(string: musicImage)
                        }
                    
                    Circle()
                        .frame(width: width / 2)
                        .foregroundColor(.black.opacity(0.5))
                        .overlay(
                            Circle()
                                .stroke(Color(uiColor: .imageColor), lineWidth: 3)
                        )
                    
                    VStack {
                        Text("BEST")
                            .foregroundColor(.white)
                            .bold()
                        Text(String(datas.bestScore()))
                            .foregroundColor(.white)
                            .fontWeight(.black)
                            .font(.largeTitle)
                             
                    }
                }
                
                LineMarkView(data: graphData(), max: datas.map{$0.score}.max()!, min: datas.map{$0.score}.min()!)
                ScrollView {
                    ForEach(datas) { data in
                        NavigationLink(destination: DetailView(data: data)) {
                            DataCell(score: data.score, time: data.time, key: data.key, model: data.model)
                            
                        }
                        .buttonStyle(DataCellStyle())
                    }
                    
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle(musicName)
            .navigationBarTitleDisplayMode(.automatic)
            .background(Color(uiColor: .baseColor))
            .toolbarBackground(Color(uiColor: .imageColor), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    func graphData() -> [GraphData] {
        return datas.map{GraphData(date: $0.time, score: $0.score)}
    }
}

#Preview {
    MusicDetailView(navigationPath: .constant(NavigationPath.init()),
                    datas: [MusicData(time: "23年03月29日20:29",
                                      score: 89.839,
                                      key: 0,
                                      model: "DAM",
                                      comment: "valdbvakjsdnvlakjndv;ak"),
                            MusicData(time: "23年09月31日20:29",
                                      score: 81.829,
                                      key: 0,
                                      model: "DAM",
                                      comment: "valdbvakjsdnvlakjndv;ak")],
                    musicName: "hogehoge",
                    musicImage: "https://ogre.natalie.mu/media/news/music/2023/0417/mrsgreenapple_jkt202304.jpg?imwidth=750&imdensity=1")
}
