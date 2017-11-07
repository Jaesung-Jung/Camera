//
//  Log.swift
//
//  Copyright (c) 2017 Jaesung Jung.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

struct Log {

    static var showsMethod = false

    private static let fileQueue = DispatchQueue(label: "Log.fileQueue", qos: .background)
    private static let dateFormatter = DateFormatter().then {
        $0.dateFormat = "HH:mm:ss.SSS"
    }

    static func trace(
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line) {
        write(.verbose, file, function, line, "")
    }

    static func v(
        _ message: @autoclosure () -> Any,
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line) {
        write(.verbose, file, function, line, message)
    }

    static func d(
        _ message: @autoclosure () -> Any,
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line) {
        write(.debug, file, function, line, message)
    }

    static func i(
        _ message: @autoclosure () -> Any,
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line) {
        write(.info, file, function, line, message)
    }

    static func w(
        _ message: @autoclosure () -> Any,
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line) {
        write(.warning, file, function, line, message)
    }

    static func e(
        _ message: @autoclosure () -> Any,
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line) {
        write(.error, file, function, line, message)
    }

    static func custom(
        _ symbol: String,
        _ message: @autoclosure () -> Any,
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line) {
        write(.custom(symbol), file, function, line, message)
    }

    private static func write(
        _ level: Log.Level,
        _ file: String,
        _ function: String,
        _ line: Int,
        _ message: @autoclosure () -> Any) {
        let time = dateFormatter.string(from: Date())
        let log = showsMethod ? "\(file.fileName).\(function)(\(line)): \(message())" : message()
        Destination.console("\(time) \(level.consoleSymbol) \(log)").write()
        Destination.file("\(time) \(level.fileSymbol) \(log)").write(fileQueue)
    }

}

extension Log {

    private enum Level {
        case verbose
        case debug
        case info
        case warning
        case error
        case custom(String)

        var consoleSymbol: String {
            switch self {
            case .verbose:
                return "💬"
            case .debug:
                return "ℹ️"
            case .info:
                return "✅"
            case .warning:
                return "⚠️"
            case .error:
                return "❌"
            case .custom(let symbol):
                return symbol
            }
        }

        var fileSymbol: String {
            switch self {
            case .verbose:
                return "V"
            case .debug:
                return "D"
            case .info:
                return "I"
            case .warning:
                return "W"
            case .error:
                return "E"
            case .custom(let symbol):
                return symbol
            }
        }
    }

}

extension Log {

    private enum Destination {
        case console(String)
        case file(String)

        func write(_ queue: DispatchQueue? = nil) {
            guard let action = action() else {
                return
            }
            if let queue = queue {
                queue.async {
                    action()
                }
            } else {
                action()
            }
        }

        func action() -> (() -> Void)? {
            switch self {
            case .console(let message):
                return {
                    print(message)
                }
            case .file:
                return nil
            }
        }

    }

}

private extension String {

    var fileName: String {
        let lastPathComponent = (self as NSString).lastPathComponent
        guard let dotIndex = lastPathComponent.index(of: ".") else {
            return lastPathComponent
        }
        let toIndex = lastPathComponent.index(before: dotIndex)
        return String(lastPathComponent[...toIndex])
    }

}
