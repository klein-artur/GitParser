//
//  LogParser.swift
//  
//
//  Created by Artur Hellmann on 03.01.23.
//

import Foundation

public struct LogResult: ParseResult {
    public var originalOutput: String
    
    public var commits: [Commit]?
    
    /// Ther commits with a nine digit commit has as key.
    public var commitShortDict: [String: Commit]?
    
    /// Ther commits with the commit has as key.
    public var commitLongDict: [String: Commit]?
}

public class LogResultParser: GitParser, Parser {
    
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
        
        do {
            let matches = result.find(rgx: #"commit\s([0-9a-fA-F]{40})(?:\s\(([^\n]+)\))?(?:\nMerge:\s([A-Fa-f0-9]{9})\s([A-Fa-f0-9]{9}))?\nAuthor:\s([^\n]+)\s<([^\n]*)>\nDate:\s+([^\n]+)\n([\s\S]*?)(?=commit\s[0-9a-fA-F]{40}(?:\s\([^\n]+\))?(?:\nMerge:\s([A-Fa-f0-9]{9})\s([A-Fa-f0-9]{9}))?\nAuthor:[^\n]+\nDate:[^\n]+|\Z)"#, options: .anchored)
            
            var commits = [Commit]()
            var commitsShort = [String: Commit]()
            var commitsLong = [String: Commit]()
            
            for match in matches {
                let commit = try parseCommit(part: match)
                commits.append(commit)
                commitsLong[commit.hash] = commit
                commitsShort[String(commit.hash.prefix(9))] = commit
            }
            
            return .success(
                LogResult(
                    originalOutput: result,
                    commits: commits,
                    commitShortDict: commitsShort,
                    commitLongDict: commitsLong
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
        guard let commitHash = part[1] else {
            throw ParseError.commitWithoutCommmitHash
        }
        
        guard let authorName = part[5], let authorEmail = part[6] else {
            throw ParseError.commitWithoutAuthor
        }
        
        guard let date = part[7]?.toDate(format: "EEE MMM dd HH:mm:ss yyyy ZZZZ") else {
            throw ParseError.commitWithoutDate
        }
        
        let (branches, tags) = parseBranchesAndTags(in: part[2] ?? "")
        
        let merges: [String] = [
            part[3],
            part[4]
        ]
            .filter { $0 != nil }
            .map { $0! }
        
        return Commit(
            hash: commitHash,
            message: part[8]?.replace(rgx: #"\n\s*"#, with: "\n").trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            author: Person(name: authorName, email: authorEmail),
            date: date,
            branches: branches,
            tags: tags,
            merges: merges
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
    
    private func parseMessage(in part: String) -> String {
        let rawMessage = part.find(rgx: #"Date:\s+.*\n\n((?:.|\n)*)"#).first?[1] ?? ""
        
        return rawMessage.replace(rgx: #"\n\s*"#, with: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
