//
//  ParserTests.swift
//  
//
//  Created by Artur Hellmann on 30.12.22.
//

@testable import GitParser

import XCTest

final class ParserTests: XCTestCase {
    
    func testNotARepo() throws {
        let result = "fatal: not a git repository (or any of the parent directories): .git"
        XCTAssertEqual(GitParser().parseForIssues(result: result), ParseError.notARepository)
    }

}
