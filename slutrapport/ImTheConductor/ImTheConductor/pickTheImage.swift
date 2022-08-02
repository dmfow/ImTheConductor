//
//  ImagePicker.swift
//  ImTheConductor
//
//  Created by .. on 2022-07-09.
//

import SwiftUI
// Use some function from the older UIKit framework
import UIKit

// To use some UIKit functions for image handling we will wrap them with UIViewControllerRepresentable which is designed for wrapping the UIKit view controller

// Define if we should use the users image library or the camera

struct pickTheImage: UIViewControllerRepresentable {
    
    // Input variables
    var imageSource: UIImagePickerController.SourceType = .photoLibrary     // .photoLibrary or .camera
    
    // Return variables
    @Binding var theSelectedImage: UIImage                  // This is the variable where the image will end up
    
    // Define the Environment to choose an image (so we can remove/dismiss it after the choice)
    @Environment(\.presentationMode) private var presentationMode
 
    // This is a UIKit function where we get the image/picture
    func makeUIViewController(context: UIViewControllerRepresentableContext<pickTheImage>) -> UIImagePickerController {
        let imgController = UIImagePickerController()       // Define the Controller
        imgController.sourceType = imageSource              // Define the source (Library or camera)
        imgController.allowsEditing = false                 // No editing of the image
        imgController.delegate = context.coordinator        // UIKit delegation design pattern through the coordinator below
        return imgController
    }
    
    // We will not update any images so this is empty
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<pickTheImage>) {
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: pickTheImage                 // Define the parent (which is this struct)
 
        // Initialize the coordinator to the parent
        init(_ parent: pickTheImage) {
            self.parent = parent
        }
 
        //  Take the image and assign it to the output variable selectedImage
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
 
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.theSelectedImage = image
            }
            
            // Always Remove/dismiss the chooser view after choosing an image (or not choosing)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    // This makes and returns an instance of the Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}
