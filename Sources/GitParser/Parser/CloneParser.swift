//
//  CloneParser.swift
//  
//
//  Created by Artur Hellmann on 03.01.23.
//

import Foundation

public struct CloneResult: ParseResult {
    public var originalOutput: String
    
    public var outputDir: String?
}

public class CloneResultParser: GitParser, Parser {
    
    public typealias Success = CloneResult
    
    override public init() {
        super.init()
    }
    
    public func parse(result: String) -> Result<Success, ParseError> {
        if let error = super.parseForIssues(result: result) {
            return .failure(error)
        }
        
        return .success(
            CloneResult(
                originalOutput: result,
                outputDir: result.find(rgx: "Cloning into '(.*)'").first?[1]
            )
        )
    }
}
