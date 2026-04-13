//
//  NDSiOSAssignmentApp.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import SwiftUI
import CoreData

@main
struct NDSiOSAssignmentApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
