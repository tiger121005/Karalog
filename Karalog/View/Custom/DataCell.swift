//
//  DataCell.swift
//  KaralogSwiftUI
//
//  Created by TAIGA ITO on 2024/07/25.
//

import SwiftUI

struct DataCell: View {
    
    var score: Double
    var time: String
    var key: Int
    var model: String
    
    var body: some View {
        VStack {
            Text(String(score))
                .fontWeight(.bold)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.top, 8)
            HStack {
                Text(time)
                Text(String(key))
                Text(model)
            }
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 10)
        
    }
}

struct DataCellStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(.black)
            .cornerRadius(10)
            .padding(.horizontal, 10)
    }
}

#Preview {
    MusicDetailView(
        navigationPath: .constant(NavigationPath.init()),
        datas: [MusicData(time: "23年03月29日20:29", score: 89.839, key: 0, model: "DAM", comment: "valdbvakjsdnvlakjndv;ak"), MusicData(time: "23年09月31日20:29", score: 81.829, key: 0, model: "DAM", comment: "valdbvakjsdnvlakjndv;ak")],
        musicName: "hogehoge", musicImage: "vbafbvla")
}
