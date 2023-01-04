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
            let matches = result.find(rgx: #"commit\s([0-9a-fA-F]{40})(?:\s\(([^\n]+)\))?\nAuthor:\s([^\n]+)\s<([^\n]*)>\nDate:\s+([^\n]+)\n([\s\S]*?)(?=commit\s[0-9a-fA-F]{40}(?:\s\([^\n]+\))?\nAuthor:[^\n]+\nDate:[^\n]+|\Z)"#, options: .anchored)
            
            var counter = 0
            print("Has \(matches.count) results.")
            let commits = try matches
                .map { commitPart in
                    counter += 1
                    print("parsing result \(counter)")
                    return try parseCommit(part: commitPart)
                }
            
            return .success(LogResult(originalOutput: result, commits: commits))
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
        
        guard let authorName = part[3], let authorEmail = part[4] else {
            throw ParseError.commitWithoutAuthor
        }
        
        guard let date = part[5]?.toDate(format: "EEE MMM dd HH:mm:ss yyyy ZZZZ") else {
            throw ParseError.commitWithoutDate
        }
        
        let (branches, tags) = parseBranchesAndTags(in: part[2] ?? "")
        
        return Commit(
            hash: commitHash,
            message: part[6]?.replace(rgx: #"\n\s*"#, with: "\n").trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            author: Person(name: authorName, email: authorEmail),
            date: date,
            branches: branches,
            tags: tags
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
