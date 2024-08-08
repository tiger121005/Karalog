//
//  SearchBar.swift
//  KaralogSwiftUI
//
//  Created by TAIGA ITO on 2024/07/29.
//

import SwiftUI

struct SearchTextFieldStyle: TextFieldStyle {
    @FocusState private var isFocused
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                
                configuration
                
                Button {
                    isFocused = false
                } label: {
                    Image(systemName: "x.circle.fill")
                        .tint(.black)
                        .bold()
                }
            }
            .frame(height: 15)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .cornerRadius(10)
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding()
        }
        .background(Color.baseColor)
    }
}

#Preview {
    VStack {
        TextField("値を入力", text: .constant(""))
            .textFieldStyle(.search)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.baseColor)
}
