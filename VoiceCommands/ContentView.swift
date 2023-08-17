//
//  ContentView.swift
//  VoiceCommands
//
//  Created by Victor Socaciu on 15/08/2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.openURL) var openURL

    var body: some View {
        ZStack {
            switch viewModel.state {
                case .checkingForPermissions:
                    Text("Checking permissions")
                case .permissionsDenied:
                    Button("Grant permissions") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                case .listeningForCommands:
                    CommandsSpeechView()
            }
        }
        .task {
            await viewModel.checkForPermissions()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
