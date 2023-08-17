//
//  VoiceCommandsApp.swift
//  VoiceCommands
//
//  Created by Victor Socaciu on 15/08/2023.
//

import SwiftUI

@main
struct VoiceCommandsApp: App {
    @StateObject var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
