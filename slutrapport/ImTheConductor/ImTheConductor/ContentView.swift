//
//  ContentView.swift
//  ImTheConductor
//
//  Created by .. on 2022-07-09.
//
import CoreData
import SwiftUI

extension Color {
    static let myButtonColor = Color(red: 250 / 255, green: 137 / 255, blue: 238 / 255)
}

struct ContentView: View {
    @ObservedObject var network = Network()

    @State private var theImage = UIImage()
    @State private var selectImage = false
    @State private var showText = false

    @State private var dispText = ""
    
    var buttonColor = UIColor(red: 250, green: 137, blue: 238, alpha: 1)

    var body: some View {

        ZStack() {
            // Image in the top
            Image(uiImage: self.theImage)
                .resizable()
                .scaledToFit()
                // .scaledToFill()

            // Buttons below
            VStack {
                Spacer()

                // Two buttons beside eachother (select the picture, get prediction from the server)
                HStack {

                    Button(action: {
                        // Clear tex from the view
                        network.clearVariable()
                        dispText = ""
                        self.showText = false
                            
                        // When the button is pushed, activate pickTheImage
                        self.selectImage = true
                            
                    }, label: {
                        Text("+")
                            // font and size of the Button
                            .font(.system(.largeTitle))
                            .frame(width: 77, height: 70)
                            .foregroundColor(Color.white)
                            .padding(.bottom, 7)
                    })
                    // Color and round button
                    .background(Color.myButtonColor)
                    .cornerRadius(38.5)
                    .padding()
                    .shadow(color: Color.black.opacity(0.3),
                        radius: 3,
                        x: 3,
                        y: 3)

                    Button(action: {
                        // When the button is pushed, communication with the server start to get a prediction
                        network.getPrediction(passTheImage: self.theImage)
                        self.showText = true

                    }, label: {
                        Text("ch.")
                        // font and size of the Button
                        .font(.system(.largeTitle))
                        .frame(width: 77, height: 70)
                        .foregroundColor(Color.white)
                        .padding(.bottom, 7)
                    })
                    // Color and round button
                    .background(Color.myButtonColor)
                    .cornerRadius(38.5)
                    .padding()
                    .shadow(color: Color.black.opacity(0.3),
                        radius: 3,
                        x: 3,
                        y: 3)
                    
                }   // HStack
                .sheet(isPresented: $selectImage) {
                    // Call another view to select the image
                    pickTheImage(imageSource: .photoLibrary, theSelectedImage: self.$theImage)
                }
            }

            // Set the prediction text aligned with the phones width
            GeometryReader { geometry in
                // Only show the text if allowed to
                if showText {
                VStack() {
                        
                    if network.things.count > 0 {
                        Text(network.things.first!.name)
                        .padding()
                        .frame(width: geometry.size.width, height: nil)
                        // Make the text background colored somewhat transparent (lower => more transparent)
                        .background(Color.white.opacity(0.6))
                        //.background(Color.gray.opacity(0.6))
                    }
                }
                .padding()
                .frame(width: geometry.size.width, height: nil)
                .background(Color.white.opacity(0))
                }
            }   // Geometry Reader
        }   // ZStack
    }   // Body
}   // View


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {

        ContentView()
            .environmentObject(Network())
    }
}



