//
//  CommandParser.swift
//  VoiceCommands
//
//  Created by Victor Socaciu on 15/08/2023.
//

import Foundation

final class CommandParser {
    private let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .spellOut
        return nf
    }()

    init() {
        numberFormatter.locale = Defaults.locale
    }

    init(locale: Locale) {
        numberFormatter.locale = locale
    }

    func parseCommandSegments(_ segments: [String]) -> [Command] {
        let segments = segments.map { $0.lowercased() }
        var commands: [Command] = []
        for var i in segments.indices {
            let commandName = segments[i]
            if let command = Commands(rawValue: commandName) {
                if command.expectsArguments {
                    var arguments: [Command.Argument] = []
                    while i < segments.endIndex - 1 {
                        let argumentIndex = i + 1
                        let argument = segments[argumentIndex]
                        guard Commands(rawValue: argument) == nil else { break }
                        if let digit = numberFromArgument(argument) {
                            arguments.append(.init(value: String(digit)))
                        }
                        i += 1
                    }
                    guard !arguments.isEmpty else { continue }
                    commands.append(.init(name: commandName, arguments: arguments))
                } else {
                    commands.append(.init(name: commandName, arguments: []))
                }
            }
        }
        return commands
    }

    private func numberFromArgument(_ argument: String) -> Int? {
        var argument = argument.replacingOccurrences(of: "-", with: "")
        argument = argument.replacingOccurrences(of: ":", with: "")
        argument = argument.replacingOccurrences(of: ",", with: "")
        if let number = Int(argument) {
            let positiveInt = abs(number)
            return positiveInt
        } else if let number = numberFormatter.number(from: argument) {
            let positiveInt = abs(number.intValue)
            return positiveInt
        }
        return nil
    }
}
