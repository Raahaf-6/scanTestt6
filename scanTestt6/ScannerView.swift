//
//  ScannerView.swift
//  scanTestt6
//
//  Created by Rahaf on 18/12/2024.
//

// ScannerView.swift
// ScannerView.swift
import SwiftUI
import VisionKit
import PhotosUI
import Vision

struct ScannerView: UIViewControllerRepresentable {
    let completion: ([String]?) -> Void

    @Binding var showPhotoPicker: Bool
    @Binding var selectedPhoto: UIImage?

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion, showPhotoPicker: $showPhotoPicker, selectedPhoto: $selectedPhoto)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let completion: ([String]?) -> Void
        @Binding var showPhotoPicker: Bool
        @Binding var selectedPhoto: UIImage?

        init(completion: @escaping ([String]?) -> Void, showPhotoPicker: Binding<Bool>, selectedPhoto: Binding<UIImage?>) {
            self.completion = completion
            _showPhotoPicker = showPhotoPicker
            _selectedPhoto = selectedPhoto
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var recognizedTexts: [String] = []

            for pageIndex in 0..<scan.pageCount {
                guard let cgImage = scan.imageOfPage(at: pageIndex).cgImage else { continue }
                let image = UIImage(cgImage: cgImage)

                recognizeText(from: image) { recognizedText in
                    if let text = recognizedText {
                        recognizedTexts.append(text)
                    }
                }
            }

            DispatchQueue.main.async {
                self.completion(recognizedTexts)
            }
            controller.dismiss(animated: true)
        }

        private func recognizeText(from image: UIImage, completionHandler: @escaping (String?) -> Void) {
            guard let cgImage = image.cgImage else {
                completionHandler(nil)
                return
            }

            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { request, error in
                guard error == nil, let results = request.results as? [VNRecognizedTextObservation] else {
                    completionHandler(nil)
                    return
                }

                let recognizedText = results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                completionHandler(recognizedText)
            }

            do {
                try requestHandler.perform([request])
            } catch {
                print("Error recognizing text: \(error)")
                completionHandler(nil)
            }
        }
    }
}

