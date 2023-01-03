//
//  Parser.swift
//  
//
//  Created by Artur Hellmann on 30.12.22.
//

import Foundation
import Combine

/// A global parsing error
public enum ParseError: Error {
    
    /// There is an issue parsing.
    case issueParsing
    
    /// Branch name could not be parsed.
    case noBranchNameFound
    
    /// The current directory is not a repository
    case notARepository
    
    /// Trying to parse a commit without a hash
    case commitWithoutCommmitHash
    
    /// Trying to parse a commit without author
    case commitWithoutAuthor
    
    /// Trying to parse a commit without date
    case commitWithoutDate
}

/// A protocol all parse results have to conform to.
public protocol ParseResult {
    var originalOutput: String { get }
}

/// Makes a git command parsable.
public protocol Parsable {
    associatedtype Success: ParseResult
    associatedtype ParserType: Parser
    
    /// Returns the parser
    var parser: ParserType { get }
    
    /// Parses only the final result of the call and returns it.
    func finalResult() async throws -> Success
    
    /// Parses contiiously until the stream finishes and emits every parse state.
    func results() -> AnyPublisher<Self.Success, ParseError>
    
    /// Runs the current command and returns a `Publisher` that emits the states of the process.
    func run() -> AnyPublisher<String, Never>
    
    /// Provides an async await style run method.
    func runAsync() async throws -> String
}

/// A parser base class to parse git results.
public protocol Parser {
    associatedtype Success: ParseResult
    
    /// parses the result by the means of the implementing class.
    func parse(result: String) -> Result<Success, ParseError>
    
}

/// A base class for parsers.
public class GitParser {
    func parseForIssues(result: String) -> ParseError? {
        if result.hasPrefix("fatal: not a git repository (or any of the parent directories):") {
            return ParseError.notARepository
        }
        return nil
    }
}

extension Parsable where Success == ParserType.Success {
    
    private func doParsing(on publisher: AnyPublisher<String, Never>) -> AnyPublisher<Success, ParseError> {
        publisher
            .flatMap(maxPublishers: .max(1)) { resultString in
                let result = parser.parse(result: resultString)
                switch result {
                case let .success(status):
                    return Just(status)
                        .setFailureType(to: ParseError.self)
                        .eraseToAnyPublisher()
                case let .failure(error):
                    return Fail<Success, ParseError>(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func finalResult() async throws -> Success {
        let result = try await self.runAsync()
        let parsedResult = parser.parse(result: result)
        switch parsedResult {
        case let .success(parsedElement):
            return parsedElement
        case let .failure(error):
            throw error
        }
    }
    
    public func results() -> AnyPublisher<Success, ParseError> {
        return doParsing(on: self.run())
    }
}
