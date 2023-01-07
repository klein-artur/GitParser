//
//  LogParser.swift
//  
//
//  Created by Artur Hellmann on 03.01.23.
//

import Foundation

public class LogResult: ParseResult {
    public var originalOutput: String
    
    public var commits: [Commit]?
    
    /// Ther commits with the commit hash as key.
    public var commitDict: [String: Commit]?
    
    public init(
        originalOutput: String,
        commits: [Commit]? = nil,
        commitDict: [String : Commit]? = nil
    ) {
        self.originalOutput = originalOutput
        self.commits = commits
        
        if let commitDict = commitDict {
            self.commitDict = commitDict
        } else if let commits = commits {
            for commit in commits {
                self.commitDict?[commit.objectHash] = commit
            }
        }
    }
}

public class LogResultParser: GitParser, Parser {
    
    /// This parser needs this format to parse the commit correctly.
    public static let prettyFormat = "<<<----mCommitm---->>>%n%h%n%d%n%H%n%P%n%an <%ae>%n%aD%n%cn <%ce>%n%cD%n%s%n%B"
    
    public typealias Success = LogResult
    
    override public init() {
        super.init()
    }
    
    public func parse(result: String) -> Result<Success, ParseError> {
        if let error = super.parseForIssues(result: result) {
            return .failure(error)
        }
        
        if result.hasPrefix("fatal: "){
            return .success(LogResult(originalOutput: result, commits: []))
        }
        
        if !result.contains("<<<----mCommitm---->>>") {
            return .failure(ParseError.wrongLogFormat)
        }
        
        do {
            let matches = result.find(rgx: #"([0-9a-fA-F]+)\n(?:\s\(([^\n]+)\))?\n([0-9a-fA-F]{40})\n((?:[0-9a-fA-F]{40}\s?)*)\n([^\n]+)\s<([^\n]*)>\n([^\n]+)\n([^\n]+)\s<([^\n]*)>\n([^\n]+)\n(.*)\n([\s\S]*?)(?=<<<----mCommitm---->>>|\Z)"#)
            
            var commits = [Commit]()
            var commitsLong = [String: Commit]()
            
            for match in matches {
                let commit = try parseCommit(part: match)
                commits.append(commit)
                commitsLong[commit.objectHash] = commit
            }
            
            return .success(
                LogResult(
                    originalOutput: result,
                    commits: commits,
                    commitDict: commitsLong
                )
            )
        } catch {
            if let parseError = error as? ParseError {
                return .failure(parseError)
            } else {
                return .success(LogResult(originalOutput: result, commits: []))
            }
        }
    }
    
    private func parseCommit(part: RgxResult) throws -> Commit {
        
        guard let shortHash = part[1] else {
            throw ParseError.commitWithoutCommmitHash
        }
        
        guard let commitHash = part[3] else {
            throw ParseError.commitWithoutCommmitHash
        }
        
        guard let authorName = part[5], let authorEmail = part[6] else {
            throw ParseError.commitWithoutAuthor
        }
        
        guard let authorDate = part[7]?.toDate(format: "EEE, dd MMM yyyy HH:mm:ss ZZZZ") else {
            throw ParseError.commitWithoutDate
        }
        
        guard let committerName = part[8], let committerEmail = part[9] else {
            throw ParseError.commitWithoutAuthor
        }
        
        guard let committerDate = part[10]?.toDate(format: "EEE, dd MMM yyyy HH:mm:ss ZZZZ") else {
            throw ParseError.commitWithoutDate
        }
        
        let (branches, tags) = parseBranchesAndTags(in: part[2] ?? "")
        
        let parents: [String] = part[4]?.split(separator: " ").map({ String($0) }).filter({ !$0.isEmpty }) ?? []
        
        return Commit(
            objectHash: commitHash,
            shortHash: shortHash,
            subject: part[11]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            message: part[12]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            author: Person(name: authorName, email: authorEmail),
            authorDate: authorDate,
            committer: Person(name: committerName, email: committerEmail),
            committerDate: committerDate,
            branches: branches,
            tags: tags,
            parents: parents
        )
    }
    
    private func parseBranchesAndTags(in part: String) -> ([String], [String]) {
        
        var branches = [String]()
        var tags = [String]()
        
        part.split(separator: ", ")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .forEach { string in
                if !string.contains(":") {
                    if string.contains("->") {
                        branches.append(String(string.split(separator: " -> ")[1]))
                    } else {
                        branches.append(string)
                    }
                } else {
                    let parts = string.split(separator: ": ")
                    
                    if parts[0] == "tag" {
                        tags.append(String(parts[1]))
                    }
                }
            }
        
        return (branches, tags)
    }
}
