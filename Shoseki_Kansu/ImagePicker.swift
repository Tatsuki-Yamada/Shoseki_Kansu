//
//  ImagePicker.swift
//  Shoseki_Kansu
//
//  Created by hw19a050 on 2021/10/26.
//

import Foundation
import SwiftUI

class ImagePickerCoordinator: NSObject,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    @Binding var image: UIImage?
    
    init(image: Binding<UIImage?>){
        _image = image
    }
    
    func imagePickerController( picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = uiImage
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIHostingController
    typealias Coordinator = ImagePickerCoordinator
    
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .camera
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context:
        UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> ImagePicker.Coordinator {
        return ImagePickerCoordinator(image: $image)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
}
