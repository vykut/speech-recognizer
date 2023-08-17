//
//  CommandsInterpreter.swift
//  VoiceCommands
//
//  Created by Victor Socaciu on 17/08/2023.
//

import Foundation

final class CommandsInterpreter {
    func interpret(_ commands: [Command]) -> [Command] {
        var commands = commands
        if let lastResetIndex = commands.lastIndex(where: { $0.name == Commands.reset.rawValue }) {
            commands.removeFirst(lastResetIndex + 1)
        }
        while let backIndex = commands.firstIndex(where: { $0.name == Commands.back.rawValue }) {
            let beforeIndex = commands.index(before: backIndex)
            if beforeIndex >= commands.startIndex {
                commands.remove(at: beforeIndex) // remove command prior to 'back'
                commands.remove(at: beforeIndex) // remove command 'back'
            } else {
                commands.remove(at: backIndex) // remove command 'back'
            }
        }
        return commands
    }
}
