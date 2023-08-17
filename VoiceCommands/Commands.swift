//
//  Commands.swift
//  VoiceCommands
//
//  Created by Victor Socaciu on 15/08/2023.
//

import Foundation

enum Commands: String {
    case code
    case count
    case back
    case reset

    var expectsArguments: Bool {
        switch self {
            case .code:
                return true
            case .count:
                return true
            case .reset:
                return false
            case .back:
                return false
        }
    }
}
