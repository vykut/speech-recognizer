//
//  SpeechRecognizer.swift
//  VoiceCommands
//
//  Created by Victor Socaciu on 15/08/2023.
//

import Foundation
import AVFoundation
import Speech

actor SpeechRecognizer {
    private let bus = 0

    private var inputNode: AVAudioInputNode {
        audioEngine.inputNode
    }
    private var task: SFSpeechRecognitionTask?

    private let audioSession = AVAudioSession.sharedInstance()
    private let audioEngine = AVAudioEngine()
    private let recognizer: SFSpeechRecognizer

    init() {
        recognizer = .init(locale: Defaults.locale)!
    }

    init?(locale: Locale) {
        guard let recognizer = SFSpeechRecognizer(locale: locale) else { return nil }
        self.recognizer = recognizer
    }

    func checkForPermissions() async throws {
        guard await SFSpeechRecognizer.hasAuthorizationToRecognize(),
              await audioSession.hasPermissionToRecord() else {
            throw Error.missingPermissions
        }
    }

    func startTranscribing() throws -> AsyncStream<[String]> {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.taskHint = .dictation

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: bus)
        inputNode.installTap(onBus: bus, bufferSize: 8192, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()

        var continuation: AsyncStream<[String]>.Continuation!
        let stream = AsyncStream { continuation = $0 }
        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let result else {
                self?.stopTranscribing()
                return continuation.finish()
            }

            if error != nil {
                self?.stopTranscribing()
                return continuation.finish()
            }

            continuation.yield(result.bestTranscription.segments.map(\.substring))
            if result.isFinal {
                continuation.finish()
            }
        }
        return stream
    }

    func stopTranscribing() {
        task?.cancel()
        inputNode.removeTap(onBus: bus)
        audioEngine.stop()
    }
}

extension SpeechRecognizer {
    enum Error: Swift.Error {
        case missingPermissions
    }
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
