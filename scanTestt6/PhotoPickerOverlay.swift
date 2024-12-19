//
//  PhotoPickerOverlay.swift
//  scanTestt6
//
//  Created by Rahaf on 18/12/2024.
//

import SwiftUI

struct PhotoPickerOverlay: View {
    let onAlbumTapped: () -> Void

    var body: some View {
        VStack {
                   Spacer()  // Push content to the bottom
                   HStack {
                       Spacer()  // Push content to the right
                       Button(action: {
                           onAlbumTapped()
                       }) {
                           Image(systemName: "photo")
                               .resizable()
                               .scaledToFit()
                               .frame(width: 50, height: 50)
                               .foregroundColor(.white)
                               .padding(12)
                               .background(Color.black.opacity(0.7))
                               .clipShape(Circle())
                       }
                       .padding(.bottom, 20)
                       .padding(.trailing, 20)
                   }
               }
    }
}
