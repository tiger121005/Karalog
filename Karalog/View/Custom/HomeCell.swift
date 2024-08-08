//
//  HomeCell.swift
//  KaralogSwiftUI
//
//  Created by TAIGA ITO on 2024/07/25.
//

import Foundation
import SwiftUI

struct HomeCell: View {
    var musicName: String
    var artistName: String
    var musicImage: String

    @State var favorite: Bool
    @State var image: UIImage = .noImage.withTintColor(.white)
    @State var data: [MusicData]

    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .frame(width: 60, height: 60, alignment: .leading)
                .cornerRadius(8)
                .task {
                    self.image = await UIImage.fromString(string: musicImage)
                }
            VStack {
                Text(musicName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(artistName)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack {
                Text(String(data.bestScore()))
                    .padding(.bottom, 5)
                    .frame(width: 65)
                Button(
                    action: {
                        self.favorite.toggle()
                    },
                    label: {
                        Image(systemName: favorite ? "star.fill" : "star")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color(uiColor: .imageColor))
                            .frame(height: 30)
                    })
            }
        }
        .frame(alignment: .leading)
        .padding(.horizontal, 20)
    }

}

struct HomeCellStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 100)
            .padding(.horizontal, 5)
            .foregroundColor(.white)
            .background(.black)
            .cornerRadius(30)
    }
}

#Preview {
    HomeView()
}
