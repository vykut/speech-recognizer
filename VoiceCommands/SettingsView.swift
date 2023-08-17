//
//  SettingsView.swift
//  VoiceCommands
//
//  Created by Victor Socaciu on 17/08/2023.
//

import SwiftUI

struct SettingsView: View {
    @State var locale: String = "en"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Language", selection: $locale) {
                        Text("English")
                            .tag("en")
                        Text("Spanish")
                            .tag("es")
                    }
                    .pickerStyle(.menu)
                    .disabled(true)
                } footer: {
                    Text("Note: Changing language doesn't currently work")
                }
            }
            .tint(.primary)
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
