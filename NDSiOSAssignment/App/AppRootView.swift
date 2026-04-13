//
//  AppRootView.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import SwiftUI

struct AppRootView: View {
    let container: AppContainer

    var body: some View {
        NavigationStack {
            DigimonListView(
                viewModel: container.makeDigimonListViewModel(),
                container: container
            )
                .navigationTitle("Digimon")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
