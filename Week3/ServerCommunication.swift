//
//  ServerCommunication.swift
//  ImTheConductor
//
//  Created by .. on 2022-07-10.
//


import SwiftUI
    
    
class Network: NSObject, URLSessionDelegate, ObservableObject {
    @Published var things: [Thing] = []

    func getInfo(passTheImage: UIImage) {
        let url = URL(string: "https://127.0.0.1:5000/")!

        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue:nil)
        let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60.0)

        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }

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

