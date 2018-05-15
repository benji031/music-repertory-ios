//
//  Log.swift
//  openbleam-app-ios
//
//  Created by Benjamin DENEUX on 06/02/2018.
//  Copyright © 2018 Ubleam. All rights reserved.
//

import Foundation

public enum LogLevel: CustomStringConvertible {
    case info
    case debug
    case warning
    case error
    
    public var description: String {
        get {
            switch self {
            case .info:
                return "INFO"
            case .debug:
                return "DEBUG"
            case .warning:
                return "WARNING"
            case .error:
                return "ERROR"
            }
        }
    }
}


public func Log(_ message: String = "", level: LogLevel = .debug, filePath: String = #file, line: Int = #line, function: String = #function) {
    #if LOG_ENABLE
        
        // Get the current thread if this information is needed to display in the log.
        var threadName = ""
        #if kLOG_THREADS
            threadName = Thread.current.isMainThread ? "MAIN THREAD" : (Thread.current.name ?? "UNKNOWN THREAD")
            threadName = "[" + threadName + "] "
        #endif
        
        
        // Allow display all logs
        #if LOG_DETAIL_INFO
            _writeLog(message, level: level, filePath: filePath, line: line, function: function, threadName: threadName)
            
            
            // Allow dislpay all log after debug
        #elseif LOG_DETAIL_DEBUG
            if level != .info {
                _writeLog(message, level: level, filePath: filePath, line: line, function: function, threadName: threadName)
            }
        #elseif LOG_DETAIL_WARNING
            if level == .warning || level == .error {
                _writeLog(message, level: level, filePath: filePath, line: line, function: function, threadName: threadName)
            }
        #elseif LOG_DETAIL_ERROR
            if level == .error {
                _writeLog(message, level: level, filePath: filePath, line: line, function: function, threadName: threadName)
            }
        #endif
    #endif
}

private func _writeLog(_ message: String, level: LogLevel, filePath: String, line: Int, function: String, threadName: String) {
    
    let fileName = NSURL(fileURLWithPath: filePath).deletingPathExtension?.lastPathComponent ?? "???"
    
    var msg = ""
    if message != "" {
        msg = " - \(message)"
    }
    
    let completeMessage: String = level.description + " : [" + threadName + fileName + "(\(line))" + " -> " + function + "]" + msg
    
    NSLog(completeMessage)
}
