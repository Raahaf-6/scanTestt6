//
//  ScannerView.swift
//  scanTestt6
//
//  Created by Rahaf on 18/12/2024.
//
import SwiftUI
import VisionKit
import PhotosUI
import Vision

struct ScannerView: UIViewControllerRepresentable {
    let completion: ([String]?) -> Void
    @Binding var showPhotoPicker: Bool
    @Binding var selectedPhoto: UIImage?

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator

        return viewController
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        context.coordinator.attachOverlay(to: uiViewController)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion, showPhotoPicker: $showPhotoPicker, selectedPhoto: $selectedPhoto)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate, PHPickerViewControllerDelegate {
        let completion: ([String]?) -> Void
        @Binding var showPhotoPicker: Bool
        @Binding var selectedPhoto: UIImage?
        var hostingController: UIHostingController<PhotoPickerOverlay>?

        init(completion: @escaping ([String]?) -> Void, showPhotoPicker: Binding<Bool>, selectedPhoto: Binding<UIImage?>) {
            self.completion = completion
            _showPhotoPicker = showPhotoPicker
            _selectedPhoto = selectedPhoto
        }

        func attachOverlay(to controller: VNDocumentCameraViewController) {
            let overlay = PhotoPickerOverlay(onAlbumTapped: {
                self.openPhotoPicker(from: controller)
            })

            let hostingController = UIHostingController(rootView: overlay)
            hostingController.view.backgroundColor = .clear
            hostingController.view.frame = controller.view.bounds
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false

            controller.addChild(hostingController)
            controller.view.addSubview(hostingController.view)
            hostingController.didMove(toParent: controller)

            self.hostingController = hostingController

            NSLayoutConstraint.activate([
                hostingController.view.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor, constant: -20),
                hostingController.view.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor, constant: -50),
                hostingController.view.widthAnchor.constraint(equalToConstant: 20),
                hostingController.view.heightAnchor.constraint(equalToConstant: 20)
            ])
        }

        func openPhotoPicker(from controller: UIViewController) {
            var config = PHPickerConfiguration()
            config.filter = .images
            config.selectionLimit = 1

            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self

            controller.present(picker, animated: true)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var recognizedTexts: [String] = []

            for pageIndex in 0..<scan.pageCount {
                guard let cgImage = scan.imageOfPage(at: pageIndex).cgImage else { continue }
                let image = UIImage(cgImage: cgImage)

                recognizeText(from: image) { text in
                    if let recognizedText = text {
                        recognizedTexts.append(recognizedText)
                    }
                }
            }

            DispatchQueue.main.async {
                self.completion(recognizedTexts)
            }
            controller.dismiss(animated: true)
        }

        func recognizeText(from image: UIImage, completionHandler: @escaping (String?) -> Void) {
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
                print("Text recognition error: \(error)")
                completionHandler(nil)
            }
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else { return }

            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                if let uiImage = image as? UIImage {
                    self?.selectedPhoto = uiImage
                    self?.showPhotoPicker = false
                    self?.recognizeText(from: uiImage) { recognizedText in
                        self?.completion([recognizedText].compactMap { $0 })
                    }
                }
            }
        }
    }
}

// SwiftUI view to overlay the album button
struct PhotoPickerOverllay: View {
    let onAlbumTapped: () -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()

                Button(action: onAlbumTapped) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .scaledToFit()
//                    reduce the size for width and height ?????????????
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(.bottom, 20)
                .padding(.trailing, 20)
            }
        }
    }
}

