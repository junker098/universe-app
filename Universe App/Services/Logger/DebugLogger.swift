//
//  DebugLogger.swift
//  Universe App
//
//  Created by Yuriy on 21.03.2024.
//

import Foundation

class DebugLogger {
    
    enum EventType: String {
        case debug = "DEBUG: - "
        case error = "ERROR: - "
        case info = "INFO: - "
    }
    
    static let shared = DebugLogger()
    private init() {}
    
    func logEvent(type: EventType, object: Any) {
        print("\(type.rawValue) \(object)")
    }
}
