//
//  ContentView.swift
//  scanTestt6
//
//  Created by Rahaf on 18/12/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showScanner = false
    @State private var recognizedText = ""
    @State private var showPhotoPicker = false
    @State private var selectedPhoto: UIImage?

    var body: some View {
        NavigationView {
            VStack {
                if !recognizedText.isEmpty {
                    ScrollView {
                        Text(recognizedText)
                            .font(.custom("MaqrooFont", size: 18))
                    }
                }

                Button("Start Scanning") {
                    showScanner = true
                }
                .sheet(isPresented: $showScanner) {
                    ScannerView(
                        completion: { texts in
                            if let texts = texts {
                                recognizedText = texts.joined(separator: "\n")
                            }
                            showScanner = false
                        },
                        showPhotoPicker: $showPhotoPicker,
                        selectedPhoto: $selectedPhoto
                    )
                }
            }
        }
    }
}



#Preview {
    ContentView()
}

