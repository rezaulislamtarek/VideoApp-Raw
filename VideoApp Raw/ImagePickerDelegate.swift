//
//  ImagePickerDelegate.swift
//  VideoApp Raw
//
//  Created by Rezaul Islam on 11/6/24.
//

import Foundation
import UIKit
import SwiftUI

struct ImagePickerDelegate: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let mediaTypes: [String]
    let didPickVideo: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = mediaTypes
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(didPickVideo: didPickVideo)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let didPickVideo: (URL) -> Void
        
        init(didPickVideo: @escaping (URL) -> Void) {
            self.didPickVideo = didPickVideo
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                didPickVideo(videoURL)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
