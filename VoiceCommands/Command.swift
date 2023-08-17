//
//  Command.swift
//  VoiceCommands
//
//  Created by Victor Socaciu on 15/08/2023.
//

import Foundation

struct Command: Identifiable, Hashable {
    let id = UUID()
    let date = Date()
    let name: String
    let arguments: [Argument]
}

extension Command {
    struct Argument: Identifiable, Hashable {
        let id = UUID()
        let value: String
    }
}
