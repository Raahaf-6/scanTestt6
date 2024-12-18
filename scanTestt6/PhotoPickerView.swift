//
//  PhotoPickerView.swift
//  scanTestt6
//
//  Created by Rahaf on 18/12/2024.
//

// PhotoPickerView.swift
import SwiftUI
import PhotosUI

struct PhotoPickerView: UIViewControllerRepresentable {
    var completionHandler: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator

        return controller
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(completionHandler: completionHandler)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var completionHandler: (UIImage?) -> Void

        init(completionHandler: @escaping (UIImage?) -> Void) {
            self.completionHandler = completionHandler
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else {
                completionHandler(nil)
                return
            }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.completionHandler(image as? UIImage)
                    }
                }
            }
        }
    }
}
