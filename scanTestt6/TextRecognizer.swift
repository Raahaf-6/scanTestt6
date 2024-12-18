//
//  TextRecognizer.swift
//  scanTestt6
//
//  Created by Rahaf on 18/12/2024.
//

import Foundation
import Vision
import UIKit
import VisionKit

final class TextRecognizer {
    let cameraScan: VNDocumentCameraScan

    init(cameraScan: VNDocumentCameraScan) {
        self.cameraScan = cameraScan
    }

    func recognizeText(from image: UIImage, completionHandler: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completionHandler(nil)
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest()

        do {
            try requestHandler.perform([request])
            let recognizedText = request.results?.compactMap {
                ($0 as? VNRecognizedTextObservation)?.topCandidates(1).first?.string
            }
            completionHandler(recognizedText?.joined(separator: "\n"))
        } catch {
            print("Unable to recognize text.")
            completionHandler(nil)
        }
    }
}


