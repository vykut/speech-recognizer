//
//  ViewModel.swift
//  VoiceCommands
//
//  Created by Victor Socaciu on 15/08/2023.
//

import Foundation
import AsyncAlgorithms

@MainActor
final class ViewModel: ObservableObject {
    private let speechRecognizer = SpeechRecognizer()
    private let commandParser = CommandParser()
    private let commandsInterpreter = CommandsInterpreter()

    @Published var state: State = .checkingForPermissions
    @Published var commands: [Command] = []
    @Published var rawInput: String = ""
    @Published var speechState: SpeechState = .stopped
    var isListening: Bool {
        speechState == .listening || speechState == .waitingForCommands
    }

    func checkForPermissions() async {
        do {
            try await speechRecognizer.checkForPermissions()
            state = .listeningForCommands
        } catch {
            state = .permissionsDenied
        }
    }

    func startListeningForCommands() async {
        guard let stream = try? await speechRecognizer.startTranscribing() else { return }
        commands = []
        rawInput = ""
        speechState = .waitingForCommands
        var timer: Timer?
        for await words in stream.throttle(for: .seconds(0.5)) {
            speechState = .listening
            let commands = commandParser.parseCommandSegments(words)
            self.commands = commandsInterpreter.interpret(commands)
            rawInput = words.joined(separator: ", ")
            timer?.invalidate()
            timer = .scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
                self?.speechState = .waitingForCommands
            }
        }
        timer?.invalidate()
        speechState = .stopped
    }

    func stopListeningForCommands() async {
        await speechRecognizer.stopTranscribing()
        speechState = .stopped
    }

    func didTapSpeechButton() {
        Task {
            if isListening {
                await stopListeningForCommands()
            } else {
                await startListeningForCommands()
            }
        }
    }
}

extension ViewModel {
    enum State: Identifiable, Hashable {
        case checkingForPermissions
        case permissionsDenied
        case listeningForCommands

        var id: Self { self }
    }

    enum SpeechState: Identifiable, Hashable {
        case stopped
        case waitingForCommands
        case listening

        var id: Self { self }
    }
}
