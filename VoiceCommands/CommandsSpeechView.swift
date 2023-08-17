//
//  CommandsSpeechView.swift
//  VoiceCommands
//
//  Created by Victor Socaciu on 15/08/2023.
//

import SwiftUI

struct CommandsSpeechView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var isRawInputSheetShown: Bool = false
    @State var isSettingsSheetShown: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        if !viewModel.commands.isEmpty {
                            commandsList
                        } else {
                            Text("No commands issued yet")
                        }
                    }
                    .onChange(of: viewModel.commands) { newCommands in
                        if let last = newCommands.last {
                            proxy.scrollTo(last.id)
                        }
                    }
                }
                if !viewModel.rawInput.isEmpty {
                    rawInputView
                }
                speechView
            }
            .padding(.horizontal)
            .navigationTitle("Issue commands")
            .toolbar {
                Button {
                    isSettingsSheetShown = true
                } label: {
                    Image(systemName: "gearshape.fill")
                }
            }
            .tint(.primary)
            .sheet(isPresented: $isRawInputSheetShown) {
                RawInputView()
            }
            .sheet(isPresented: $isSettingsSheetShown) {
                SettingsView()
            }
        }
        .animation(.linear, value: viewModel.isListening)
        .task {
            await viewModel.startListeningForCommands()
        }
    }

    var speechView: some View {
        Button {
            viewModel.didTapSpeechButton()
        } label: {
            HStack {
                Text({ () -> String in
                    switch viewModel.speechState {
                        case .listening:
                            return "Listening"
                        case .stopped:
                            return "Restart"
                        case .waitingForCommands:
                            return "Waiting for your next command"
                    }
                }())
                .animation(.default, value: viewModel.speechState)
                Spacer()
                Image(systemName: viewModel.isListening ? "stop.circle" : "play.circle")
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .foregroundColor({
                        switch viewModel.speechState {
                            case .listening:
                                return .green
                            case .waitingForCommands:
                                return .purple
                            case .stopped:
                                return .red
                        }
                    }())
                    .animation(.default, value: viewModel.speechState)
            }
        }
        .buttonStyle(.plain)
    }

    var commandsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(viewModel.commands) { command in
                VStack(alignment: .leading) {
                    HStack {
                        Text("Command")
                        Text(command.name)
                            .fontWeight(.medium)
                    }
                    if !command.arguments.isEmpty {
                        argumentsList(for: command)
                    }
                }
                .font(.title2)
                .id(command.id)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.linear, value: viewModel.commands)
    }

    func argumentsList(for command: Command) -> some View {
        HStack {
            Text("Value")
            Text(command.arguments.map(\.value).joined())
                .fontWeight(.medium)
        }
    }

    var rawInputView: some View {
        HStack {
            Text("Input")
            Text(viewModel.rawInput)
                .fontWeight(.medium)
                .lineLimit(1)
                .truncationMode(.head)
            Spacer()
            Button {
                isRawInputSheetShown = true
            } label: {
                Image(systemName: "chevron.right.circle.fill")
            }
        }
        .font(.title3)
        .animation(.linear, value: viewModel.rawInput)
    }
}

struct CommandsSpeechView_Previews: PreviewProvider {
    static var previews: some View {
        CommandsSpeechView()
            .environmentObject(ViewModel())
    }
}
