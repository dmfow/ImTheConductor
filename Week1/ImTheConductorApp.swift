//
//  ImTheConductorApp.swift
//  ImTheConductor
//
//  Created by .. on 2022-07-09.
//

import SwiftUI

@main
struct ImTheConductorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
