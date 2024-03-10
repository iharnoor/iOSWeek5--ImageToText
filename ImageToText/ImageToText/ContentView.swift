//
//  ContentView.swift
//  ImageToText
//
//  Created by Harnoor Singh on 3/10/24.
//

import SwiftUI
import Vision

struct ContentView: View {
    
    @State private var uiImage: UIImage? = nil // nil 
    @State private var recognizedText: String = ""
    
    var body: some View {
        VStack {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.blue)
                    .dynamicTypeSize(/*@START_MENU_TOKEN@*/.xLarge/*@END_MENU_TOKEN@*/)
            }
            Text(recognizedText.isEmpty ? "Tap the button to Convert to text" : recognizedText)
                .padding()
            Button("Image To Text") {
                self.uiImage = UIImage(named: "screenshot")
                if self.uiImage != nil {
                    processImage(uiImage: self.uiImage!)
                }
            }
        }
        .padding()
    }

    func processImage(uiImage: UIImage) -> Void {
        // 1 convert UiImage to CgImage
        guard let cgImage = uiImage.cgImage else {
            print("Failed to convert to CgImage")
            return
        }
        // 2 create an Image Handler
        let imageRequestHandler = VNImageRequestHandler(cgImage:cgImage)
        
        // 3 Request for converting cGImage into Text (New Thread or async process
        let request = VNRecognizeTextRequest { request, error in
            // Step 4 to convert Request to Observation
            guard let results = request.results as? [VNRecognizedTextObservation],
                  error == nil // no error
            else { /// if error !=nil that means error has occured (error =something
                print("Error found in converting to VNRecognizedTextObservation", error?.localizedDescription)
                recognizedText = "Error found in converting to VNRecognizedTextObservation \(error?.localizedDescription)"
                return
            }
            // Step 5 use result
            let outputText = results.compactMap { observation in
                observation.topCandidates(1).first?.string // combine into 1 object
            }.joined(separator: "\n")
            // Step 6 make sure when you set the text it should be in UI Thread / main thread
            DispatchQueue.main.async {
                recognizedText = outputText
            }
        }
        // Step 7 to perform request
        // Send the requests to the request handler.
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([request])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
//                self.presentAlert("Image Request Failed", error: error)
                return
            }
        }
        
        
    }
    
}

#Preview {
    ContentView()
}
