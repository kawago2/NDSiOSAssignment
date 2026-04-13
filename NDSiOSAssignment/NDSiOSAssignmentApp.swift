//
//  NDSiOSAssignmentApp.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import SwiftUI

@main
struct NDSiOSAssignmentApp: App {
    private let container = AppContainer.shared

    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
        }
    }
}
