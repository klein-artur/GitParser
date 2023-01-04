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
        commit 91a36920b1ec069004fef9dc41b7c5dbcaa5fffe (HEAD -> main, tag: testtag, origin/main, origin/HEAD)
        Author: John Doe <johndoe.thats@testl.com>
        Date:   Sun Nov 27 08:42:53 2022 +0200

            Update CI for Xcode 14 and 13 (#2455)

        commit 8ec08deca8271516f673706e78fb954797cd6627
        Author: John Doé <johndoe.thats@testl.com>
        Date:   Mon Oct 24 18:31:05 2022 +0900

            Update documentation comments for example code (#2460)

        commit ab09f6966d5a14ffe6a7b960cc414ac85468b60b
        Author: John Doe <johndoe.thats@testl.com>
        Date:   Fri Sep 9 08:17:53 2022 -0400

            Table/CollectionViewDelegateProxy crash workaround
            
            Implement crash workaround discussed here https://github.com/ReactiveX/RxSwift/issues/2428 until a more permanent solution is found

        commit 3b2fe19de57720f4a6505a5f9982c5b801f753a1
        Author: John Doe <johndoe.thats@testl.com>
        Date:   Tue Sep 27 10:41:55 2022 -0700

            Fix grammar in README.md

        commit 23fe3fa469f59f168841964bcfe70f5871f6bd25
        Author: John Doe <johndoe.thats@testl.com>
        Date:   Wed Sep 22 18:09:52 2021 +0300

            Concurrency Import incantation

        commit 941f3deb822b2e83c327c1bd67553701720df8f8
        Author: John Doe <>
        Date:   Thu Sep 24 23:28:55 2020 +0300
            Enable 'Build active schemes'
            
            (cherry picked from
        
        commit 682a75ad45f9b1ffb697b67b8b47cd9af5d50fe4
        
        )

        commit 941f3deb822b2e83c327c1bd67553701720df8f8
        Author: freak4pc <freak4pc@gmail.com>
        Date:   Thu Sep 24 23:28:55 2020 +0300
            Enable 'Build active schemes'
            
            (cherry picked from commit 682a75ad45f9b1ffb697b67b8b47cd9af5d50fe4)

        commit a5fb5808e2bcd2cab1bf663d4a4738c842eab5c8
        Author: John Doe <johndoe.thats@testl.com>
        Date:   Tue Apr 5 22:23:09 2022 +0000

            Bump cocoapods-downloader from 1.4.0 to 1.6.3
            
            Bumps [cocoapods-downloader](https://github.com/CocoaPods/cocoapods-downloader) from 1.4.0 to 1.6.3.
            - [Release notes](https://github.com/CocoaPods/cocoapods-downloader/releases)
            - [Changelog](https://github.com/CocoaPods/cocoapods-downloader/blob/master/CHANGELOG.md)
            - [Commits](https://github.com/CocoaPods/cocoapods-downloader/compare/1.4.0...1.6.3)
            
            ---
            updated-dependencies:
            - dependency-name: cocoapods-downloader
              dependency-type: indirect
            ...
            
            Signed-off-by: dependabot[bot] <support@github.com>

        commit a9cf4550d5b57c9bc0f04a8c54a33e041a378fb4
        Author: John Doe <johndoe.thats@testl.com>
        Date:   Tue May 24 13:42:45 2022 +0900

            Fix: Class Unavailable on Main.storyboard (#2412)


        """
        
        // when
        let result = sut.parse(result: input)
        let parsedLog = try! result.get()
        
        // then
        XCTAssertNotNil(parsedLog.commits)
        XCTAssertEqual(parsedLog.commits?.count, 9)
        XCTAssertEqual(parsedLog.commits?[0].hash, "91a36920b1ec069004fef9dc41b7c5dbcaa5fffe")
        XCTAssertEqual(parsedLog.commits?[0].branches.count, 3)
        XCTAssertEqual(parsedLog.commits?[0].branches[0], "main")
        XCTAssertEqual(parsedLog.commits?[0].branches[1], "origin/main")
        XCTAssertEqual(parsedLog.commits?[0].tags.count, 1)
        XCTAssertEqual(parsedLog.commits?[0].tags[0], "testtag")
        XCTAssertEqual(parsedLog.commits?[0].author.name, "John Doe")
        XCTAssertEqual(parsedLog.commits?[0].author.email, "johndoe.thats@testl.com")
        
        let testDate = "Sun Nov 27 08:42:53 2022 +0200".toDate(format: "EEE MMM dd HH:mm:ss yyyy ZZZZ")!
        
        XCTAssertEqual(parsedLog.commits?[0].date, testDate)
        XCTAssertEqual(parsedLog.commits?[0].message, "Update CI for Xcode 14 and 13 (#2455)")
    }
    
    func testParsingLogWithEmoji() throws {
        // given
        let input = """
        commit 23fe3fa469f59f168841964bcfe70f5871f6bd25
        Author: John Doe <johndoe.thats@testl.com>
        Date:   Wed Sep 22 18:09:52 2021 +0300

            Concurrency Import incantation 🧙‍♀️

        
        """
        
        // when
        let result = sut.parse(result: input)
        let parsedResult = try! result.get()
        
        // then
        XCTAssertEqual(parsedResult.commits?[0].message, "Concurrency Import incantation 🧙‍")
    }
    
    func testParsingLogWith() throws {
        // given
        let input = """
        commit b56f7a426e0c4bf4a5a2caec5dfd80fd347f9686
        Author: John Doé <johndoe.thats@testl.com>
        Date:   Wed Feb 3 11:08:08 2021 +0100
        
            remove link with libswiftXCTest.dylib deprecated and now removed on iOS 14.5Beta, instead use its replacement, libXCTestSwiftSupport.dylib using ENABLE_TESTING_SEARCH_PATHS = YES.
        
        
        """
        
        // when
        let result = sut.parse(result: input)
        let parsedResult = try! result.get()
        
        // then
        
        let testDate = "Wed Feb 3 11:08:08 2021 +0100".toDate(format: "EEE MMM dd HH:mm:ss yyyy ZZZZ")!
        
        XCTAssertEqual(parsedResult.commits?[0].date, testDate)
    }

}
