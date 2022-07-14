//
//  ContentView.swift
//  ImTheConductor
//
//  Created by .. on 2022-07-09.
//
import CoreData
import SwiftUI

struct ContentView: View {

    @State private var theImage = UIImage()
    @State private var showImage = false
  
     var body: some View {
         VStack {
             Button(action: {
                 // Set to true to activate the .sheet => pickTheImage
                 self.showImage = true
             }) {
                 HStack {
                     Text("Take the picture")
                 }
                 .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                 .foregroundColor(.white)
                 .background(Color.purple)
             }
            Image(uiImage: self.theImage)
                .scaledToFill()
                .resizable()
         }
         .sheet(isPresented: $showImage) {
            pickTheImage(imageSource: .photoLibrary, theSelectedImage: self.$theImage)
            //pickTheImage(imageSource: .camera, theSelectedImage: self.$theImage)
         }
        
     }
    
    
}
