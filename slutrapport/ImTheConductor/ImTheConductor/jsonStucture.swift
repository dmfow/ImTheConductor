//
//  jsonStucture.swift
//  ImTheConductor
//
//  Created by .. on 2022-07-10.
//

import Foundation

struct Thing: Identifiable, Decodable {
    var id: Int
    var name: String
}
