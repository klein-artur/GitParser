//
//  ParserTestLog.swift
//  
//
//  Created by Artur Hellmann on 03.01.23.
//

@testable import GitParser

import XCTest

final class ParserTestLog: XCTestCase {
    
    var sut: LogResultParser!

    override func setUpWithError() throws {
        sut = LogResultParser()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testParsingGitLog() throws {
        // given
        let input = """
        <<<----mCommitm---->>>
        67faa10
         (HEAD -> main, origin/main, tag: test)
        67faa10a224db86ef4e796ab0a14b056ad4001a6
        da4830b5ef3697795ec38d59044291a6b2135214
        John Doe <johndoe.thats@testl.com>
        Fri, 6 Jan 2023 13:07:35 +0100
        John Doe <johndoe.thats@testl.com>
        Fri, 6 Jan 2023 13:07:35 +0100
        More hash handling improvements
        <<<----mCommitm---->>>
        da4830b
        
        da4830b5ef3697795ec38d59044291a6b2135214
        8258f9663d1fbde63d97ac9a387f6a3dddf4b801
        John Doe <johndoe.thats@testl.com>
        Fri, 6 Jan 2023 12:15:27 +0100
        John Doe <johndoe.thats@testl.com>
        Fri, 6 Jan 2023 12:15:27 +0100
        improved Hash Handling
        <<<----mCommitm---->>>
        8258f96
        
        8258f9663d1fbde63d97ac9a387f6a3dddf4b801
        b4dd6c93eec0df86b12055739db31491c59c8517 1050a3c5f6343e1bb6073df2a67566d47c11e6b2
        John Doe <johndoe.thats@testl.com>
        Thu, 5 Jan 2023 01:37:33 +0100
        John Doe <johndoe.thats@testl.com>
        Thu, 5 Jan 2023 01:37:33 +0100
        Merge branch 'main' of github.com:klein-artur/GitParser
        <<<----mCommitm---->>>
        b4dd6c9
        
        b4dd6c93eec0df86b12055739db31491c59c8517
        258ae77965e33e9885dcc8072db5f53e3bd7f22f
        John Doe <johndoe.thats@testl.com>
        Thu, 5 Jan 2023 01:37:17 +0100
        John Doe <johndoe.thats@testl.com>
        Thu, 5 Jan 2023 01:37:17 +0100
        Adding parent commits to commit
        And more
        
        lines of
        
        message
        
        stuff
        <<<----mCommitm---->>>
        1050a3c
        
        1050a3c5f6343e1bb6073df2a67566d47c11e6b2
        258ae77965e33e9885dcc8072db5f53e3bd7f22f
        John Doe <johndoe.thats@testl.com>
        Wed, 4 Jan 2023 22:15:24 +0100
        GitHub <noreply@github.com>
        Wed, 4 Jan 2023 22:15:24 +0100
        Update README.md<<<----mCommitm---->>>
        258ae77
        
        258ae77965e33e9885dcc8072db5f53e3bd7f22f
        3c393184a116f4cbfa55aeb68ca39818e76dd870
        John Doe <johndoe.thats@testl.com>
        Wed, 4 Jan 2023 14:17:40 +0100
        John Doe <johndoe.thats@testl.com>
        Wed, 4 Jan 2023 14:17:40 +0100
        parsing commitlist
        <<<----mCommitm---->>>
        3c39318
        
        3c393184a116f4cbfa55aeb68ca39818e76dd870
        01edf9e57f55d457ca84072b1a0702ba97b58c98
        John Doe <johndoe.thats@testl.com>
        Tue, 3 Jan 2023 23:26:46 +0100
        John Doe <johndoe.thats@testl.com>
        Tue, 3 Jan 2023 23:26:46 +0100
        Parsing logs
        <<<----mCommitm---->>>
        01edf9e
        
        01edf9e57f55d457ca84072b1a0702ba97b58c98
        
        John Doe <johndoe.thats@testl.com>
        Tue, 3 Jan 2023 00:18:13 +0100
        John Doe <johndoe.thats@testl.com>
        Tue, 3 Jan 2023 17:14:57 +0100
        Initial Commit
        """
        
        // when
        let result = sut.parse(result: input)
        let parsedLog = try! result.get()
        
        // then
        XCTAssertNotNil(parsedLog.commits)
        XCTAssertEqual(parsedLog.commits?.count, 8)
        XCTAssertEqual(parsedLog.commits?[0].objectHash, "67faa10a224db86ef4e796ab0a14b056ad4001a6")
        XCTAssertEqual(parsedLog.commits?[0].branches.count, 2)
        XCTAssertEqual(parsedLog.commits?[0].branches[0], "main")
        XCTAssertEqual(parsedLog.commits?[0].branches[1], "origin/main")
        XCTAssertEqual(parsedLog.commits?[0].tags.count, 1)
        XCTAssertEqual(parsedLog.commits?[0].tags[0], "test")
        XCTAssertEqual(parsedLog.commits?[0].author.name, "John Doe")
        XCTAssertEqual(parsedLog.commits?[0].author.email, "johndoe.thats@testl.com")
        
        XCTAssertEqual(parsedLog.commits?[2].parents.count, 2)
        XCTAssertEqual(parsedLog.commits?[2].parents[0], "b4dd6c93eec0df86b12055739db31491c59c8517")
        XCTAssertEqual(parsedLog.commits?[2].parents[1], "1050a3c5f6343e1bb6073df2a67566d47c11e6b2")
        
        let testDate = "Fri, 6 Jan 2023 13:07:35 +0100".toDate(format: "EEE, dd MMM yyyy HH:mm:ss ZZZZ")!
        
        XCTAssertEqual(parsedLog.commits?[0].authorDate, testDate)
        XCTAssertEqual(parsedLog.commits?[0].message, "More hash handling improvements")
        
        let otherTest = """
        Adding parent commits to commit
        And more
        
        lines of
        
        message
        
        stuff
        """
        
        XCTAssertEqual(parsedLog.commits?[3].message, otherTest)
    }
}
