//
//  ServerCommunication.swift
//  ImTheConductor
//
//  Created by .. on 2022-07-10.
//


import SwiftUI
    
    
class Network: NSObject, URLSessionDelegate, ObservableObject {
    @Published var things: [Thing] = []

    func getPrediction(passTheImage: UIImage) {
        
        // Setup IP & HTTPS communications parameters
        
        // let url = URL(string: "https://127.0.0.1:5000/")!
        let url = URL(string: "https://127.0.0.1:5000/POST/")!

        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue:nil)
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60.0)

        let httpBody = NSMutableData()
        let boundary = "Boundary-\(UUID().uuidString)"

        // base64 encode the image
        let imageData = passTheImage.jpegData(compressionQuality: 1)
        let imageBase64String = imageData?.base64EncodedString()
        if(imageData==nil)  { return; }
        
        // Make the request a multipart/form-data
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Attach the image data to the http body (and other field data)
        httpBody.append(convertFileData(fieldName: "image_field",
                                        fileName: "imagename.png",
                                        mimeType: "image/png",
                                        b64s: imageBase64String!,
                                        fileData: imageData!,
                                        using: boundary))

        httpBody.appendString("--\(boundary)--")

        // Make the request a POST request
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = httpBody as Data
        
        // Send it
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            // Take the response and process it
            guard let response = response as? HTTPURLResponse else { return }

            // If the https response is ok (statsu code 200), try do decode the message as a json string
            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let decodedThings = try JSONDecoder().decode([Thing].self, from: data)
                        self.things = decodedThings
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }
         }
         dataTask.resume()
    }
    
    
    // Delegation of URLSession, to handle Certificate credentials
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!) )
    }

    // Clears the json structure variable name (can be called from another view)
    func clearVariable() {
        self.things = []
    }
    
    // Generate a boundary string for the http body
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}


// Convert variables to a data structure usable for the http.body
func convertFileData(fieldName: String, fileName: String, mimeType: String, b64s: String, fileData: Data, using boundary: String) -> Data {
    
    let data = NSMutableData()
    data.appendString("--\(boundary)\r\n")

    let s = "Content-Disposition: form-data; name=\"file\" \r\n"

    data.appendString(s)
    data.appendString("Content-Type: \(mimeType)\r\n\r\n")
    data.appendString(b64s)
    data.appendString("\r\n")

    return data as Data
}

// Extend the NSutableData with an append function
extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}


// To override the problem with self-signed certificates
extension SecTrust {
    var isSelfSigned: Bool? {
        guard SecTrustGetCertificateCount(self) == 1 else {
            return false
        }
        guard let cert = SecTrustGetCertificateAtIndex(self, 0) else {
            return nil
        }
        return cert.isSelfSigned
    }
}

extension SecCertificate {
    var isSelfSigned: Bool? {
        guard
            let subject = SecCertificateCopyNormalizedSubjectSequence(self),
            let issuer = SecCertificateCopyNormalizedIssuerSequence(self)
        else {
            return nil
        }
        return subject == issuer
    }
}

