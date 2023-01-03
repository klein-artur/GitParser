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
        
        if result.contains("fatal") {
            return .success(LogResult(originalOutput: result, commits: []))
        }
        
        do {
            let commits = try result.split(separator: "commit ")
                .map { commitPart in
                    try parseCommit(part: String(commitPart))
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
    
    private func parseCommit(part: String) throws -> Commit {
        guard let commitHash = part.find(rgx: #"([a-fA-F0-9]{40})\s"#).first?[1] else {
            throw ParseError.commitWithoutCommmitHash
        }
        
        let (branches, tags) = parseBranchesAndTags(in: part)
        
        return Commit(
            hash: commitHash,
            message: parseMessage(in: part),
            author: try parseAuthor(in: part),
            date: try parseDate(in: part),
            branches: branches,
            tags: tags
        )
    }
    
    private func parseBranchesAndTags(in part: String) -> ([String], [String]) {
        guard let branchPart = part.find(rgx: #"[a-fA-F0-9]{40}\s\((.+)\)"#).first?[1] else {
            return ([], [])
        }
        
        var branches = [String]()
        var tags = [String]()
        
        branchPart.split(separator: ", ")
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
    
    private func parseAuthor(in part: String) throws -> Person {
        guard let foundAuthor = part.find(rgx: #"Author:\s(.*)\s<(.*)>"#).first else {
            throw ParseError.commitWithoutAuthor
        }
        
        return Person(
            name: foundAuthor[1] ?? "",
            email: foundAuthor[2] ?? ""
        )
    }
    
    private func parseDate(in part: String) throws -> Date {
        guard let foundDate = part.find(rgx: #"Date:\s+(.*)"#).first, let date = foundDate[1]?.toDate(format: "EEE MMM dd HH:mm:ss yyyy ZZZZ") else {
            throw ParseError.commitWithoutDate
        }
        
        return date
    }
    
    private func parseMessage(in part: String) -> String {
        let rawMessage = part.find(rgx: #"Date:\s+.*\n\n((?:.|\n)*)"#).first?[1] ?? ""
        
        return rawMessage.replace(rgx: #"\n\s*"#, with: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
