//
//  ParserTestClone.swift
//  
//
//  Created by Artur Hellmann on 03.01.23.
//

@testable import GitParser

import XCTest

final class ParserTestClone: XCTestCase {
    
    func testCloneDone() throws {
        // given
        let input = "Cloning into 'SomePath'..."
        
        // when
        let result = CloneResultParser().parse(result: input)
        let parsed = try! result.get()
        
        // then
        XCTAssertEqual(parsed.outputDir, "SomePath")
    }

    func testCloneNotDone() throws {
        // given
        let input = "fatal: some error occured"
        
        // when
        let result = CloneResultParser().parse(result: input)
        let parsed = try! result.get()
        
        // then
        XCTAssertNil(parsed.outputDir)
    }
}
