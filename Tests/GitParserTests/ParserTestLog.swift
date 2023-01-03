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
        Author: John Doe <johndoe.thats@testl.com>
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

        commit e0ab8c4e18baf6679a65b325155923276b832687
        Author: John Doe <johndoe.thats@testl.com>
        Date:   Fri Jun 3 22:36:26 2022 +0300

            Concurrency: Make minimum Swift version 5.6

        commit 0b73456e29b1cec2ab4bd032a6a98779bbd57d61
        Author: John Doe <johndoe.thats@testl.com>
        Date:   Sat Jun 4 03:32:35 2022 +0800

            Use AtomicInt for BooleanDisposable to prevent potential rase condition. (#2419)

        commit d2ca6aba8aceb3b88af1a81c33e7bde72d2405d7
        Author: John Doe <johndoe.thats@testl.com>
        Date:   Fri Jun 3 21:32:08 2022 +0200

            Fix for value leaks its continuation (#2427)

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
    
    func testParsingGitLogWithoutHash() throws {
        // given
        let input = """
        commit 91a36920b1ec069004fef9dc41b7c5dbcaa5fffe (HEAD -> main, tag: testtag, origin/main, origin/HEAD)
        Author: John Doe <johndoe.thats@testl.com>
        Date:   Sun Nov 27 08:42:53 2022 +0200

            Update CI for Xcode 14 and 13 (#2455)

        commit 
        Author: John Doe <johndoe.thats@testl.com>
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

        commit e0ab8c4e18baf6679a65b325155923276b832687
        Author: John Doe <johndoe.thats@testl.com>
        Date:   Fri Jun 3 22:36:26 2022 +0300

            Concurrency: Make minimum Swift version 5.6

        commit 0b73456e29b1cec2ab4bd032a6a98779bbd57d61
        Author: John Doe <johndoe.thats@testl.com>
        Date:   Sat Jun 4 03:32:35 2022 +0800

            Use AtomicInt for BooleanDisposable to prevent potential rase condition. (#2419)

        commit d2ca6aba8aceb3b88af1a81c33e7bde72d2405d7
        Author: John Doe <johndoe.thats@testl.com>
        Date:   Fri Jun 3 21:32:08 2022 +0200

            Fix for value leaks its continuation (#2427)

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
        
        // then
        switch result {
            case .success(let value):
                XCTFail("Expected to be a failure but got a success with \(value)")
            case .failure(let error):
                XCTAssertEqual(error, ParseError.commitWithoutCommmitHash)
            }
    }

}
