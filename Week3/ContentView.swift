//
//  ContentView.swift
//  ImTheConductor
//
//  Created by .. on 2022-07-09.
//
import CoreData
import SwiftUI

/*
  https://www.appcoda.com/swiftui-camera-photo-library/
  https://dev.to/maeganwilson_/how-to-present-and-dismiss-a-modal-in-swiftui-155c
  https://stackoverflow.com/questions/67071086/a-view-environmentobject-for-appinformation-may-be-missing-as-an-ancestor-of
*/

struct ContentView: View {
    @ObservedObject var network = Network()

    @State private var theImage = UIImage()
    @State private var showImage = false
//    @State private var theText = "theText"
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    // Set to true to activate the .sheet => pickTheImage
                    self.showImage = true
                })
                {
                    HStack {
                        Text("Take the picture")
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(Color.purple)
                    .foregroundColor(.white)
                }
            }
            
            Image(uiImage: self.theImage)
               .resizable()
               .scaledToFill()
            
            HStack {
                Button(action: {
                    // If this button is pushed, communication with the server start
                    network.getInfo(passTheImage: self.theImage)
                })
                {
                    HStack {
                        Text("Check item")
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(Color.purple)
                    .foregroundColor(.white)
                }
            }

        }
        .sheet(isPresented: $showImage) {
            pickTheImage(imageSource: .photoLibrary, theSelectedImage: self.$theImage)
            //pickTheImage(imageSource: .camera, theSelectedImage: self.$theImage)
        }
        

        VStack {
            ForEach(network.things) { item in
                       HStack(alignment:.top) {
                           Text("\(item.id)")
                       }
            }
        }

        VStack {
        ScrollView {
            Text("All users")
                .font(.title)
                .bold()
            
            if network.things.count > 0 {
                Text(network.things.first!.name)
            }

        }
        .padding(.vertical)
    }

        
    }
}

// More on this later, but it is needed to get the ObservableObject of Network to work
struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {

        ContentView()
            .environmentObject(Network())

    }
}





