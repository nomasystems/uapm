// Copyright 2023 Nomasystems S.L.

import Foundation

public extension Process {
    internal struct ProcessError: Error {
        let exitStatus: Int32
    }

    struct RunningProcess {
        public var result: Void {
            get async throws {
                try await _task.value
            }
        }

        let _task: Task<Void, Error>
        public let stdout: FileHandle.AsyncBytes
        public let stderr: FileHandle.AsyncBytes
    }

    static func asyncRun(url: URL, arguments: [String]) throws -> RunningProcess {
        let process = Process()
        let stdin = Pipe()
        let stdout = Pipe()
        let stderr = Pipe()
        process.executableURL = url
        process.arguments = arguments
        process.standardInput = stdin
        process.standardOutput = stdout
        process.standardError = stderr

        var resultContinuation: AsyncStream<Int32>.Continuation!
        let resultStream =
            AsyncStream<Int32>(bufferingPolicy: .bufferingNewest(1)) { continuation in
                resultContinuation = continuation
            }

        process.terminationHandler = { handler in
            resultContinuation.yield(handler.terminationStatus)
        }

        let task = Task<Void, Error> {
            var iterator = resultStream.makeAsyncIterator()
            let exitStatus = await iterator.next()!
            if exitStatus != 0 {
                throw ProcessError(exitStatus: exitStatus)
            }
        }

        try process.run()
        return RunningProcess(
            _task: task,
            stdout: stdout.fileHandleForReading.bytes,
            stderr: stderr.fileHandleForReading.bytes
        )
    }
}

public extension Process {
    static func runAndOutputError(url: URL, arguments: [String]) async throws {
        let process = try asyncRun(url: url, arguments: arguments)
        do {
            try await process.result
        } catch let error as ProcessError {
            print(
                "error: \(url.lastPathComponent) failed with exits status: \(error.exitStatus)",
                to: &Util.standardError
            )
            (try? await process.stderr.string).map { print($0, to: &Util.standardError) }
        }
    }
}

public extension FileHandle.AsyncBytes {
    var string: String {
        get async throws {
            let bytes = try await reduce(into: [UInt8](), { $0.append($1) })
            return String(decoding: bytes, as: UTF8.self)
        }
    }
}
