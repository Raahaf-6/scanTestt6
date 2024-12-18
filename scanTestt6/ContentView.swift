//
//  ContentView.swift
//  scanTestt6
//
//  Created by Rahaf on 18/12/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showScanner = false
    @State private var showPhotoPicker = false
    @State private var selectedPhoto: UIImage?
    @State private var recognizedText: String = ""

    var body: some View {
        NavigationView {
            VStack {
                if recognizedText.isEmpty {
                    Text("No text recognized yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        Text(recognizedText)
                            .font(.custom("MaqrooFont", size: 18))
                            .padding()
                    }
                }

                Button(action: {
                    showScanner = true
                }) {
                    Text("Open Camera")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .navigationTitle("Text Scanner")
            
            .sheet(isPresented: $showScanner) {
                // Pass the required parameters to ScannerView
                ScannerView(completion: { texts in
                    if let texts = texts {
                        recognizedText = texts.joined(separator: "\n")
                    }
                    showScanner = false
                }, showPhotoPicker: $showPhotoPicker, selectedPhoto: $selectedPhoto)
            }
        }
    }
}



#Preview {
    ContentView()
}

