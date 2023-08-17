//
//  RawInputView.swift
//  VoiceCommands
//
//  Created by Victor Socaciu on 17/08/2023.
//

import SwiftUI

struct RawInputView: View {
    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(viewModel.rawInput)
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .navigationTitle("Raw input")
        }
    }
}

struct RawInputView_Previews: PreviewProvider {
    static var previews: some View {
        RawInputView()
    }
}
