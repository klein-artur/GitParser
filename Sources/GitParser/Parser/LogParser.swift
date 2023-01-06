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
    
    private var commitDict3: [String: Commit]?
    private var commitDict4: [String: Commit]?
    private var commitDict5: [String: Commit]?
    private var commitDict6: [String: Commit]?
    private var commitDict7: [String: Commit]?
    private var commitDict8: [String: Commit]?
    private var commitDict9: [String: Commit]?
    private var commitDict10: [String: Commit]?
    private var commitDict11: [String: Commit]?
    private var commitDict12: [String: Commit]?
    
    /// Ther commits with the commit hash as key.
    public var commitDict: [String: Commit]?
    
    public init(
        originalOutput: String,
        commits: [Commit]? = nil,
        commitDict: [String : Commit]? = nil,
        commitDict3: [String : Commit]? = nil,
        commitDict4: [String : Commit]? = nil,
        commitDict5: [String : Commit]? = nil,
        commitDict6: [String : Commit]? = nil,
        commitDict7: [String : Commit]? = nil,
        commitDict8: [String : Commit]? = nil,
        commitDict9: [String : Commit]? = nil,
        commitDict10: [String : Commit]? = nil,
        commitDict11: [String : Commit]? = nil,
        commitDict12: [String : Commit]? = nil
    ) {
        self.originalOutput = originalOutput
        self.commits = commits
        
        self.commitDict = commitDict ?? [:]
        self.commitDict3 = commitDict3 ?? [:]
        self.commitDict4 = commitDict4 ?? [:]
        self.commitDict5 = commitDict5 ?? [:]
        self.commitDict6 = commitDict6 ?? [:]
        self.commitDict7 = commitDict7 ?? [:]
        self.commitDict8 = commitDict8 ?? [:]
        self.commitDict9 = commitDict9 ?? [:]
        self.commitDict10 = commitDict10 ?? [:]
        self.commitDict11 = commitDict11 ?? [:]
        self.commitDict12 = commitDict12 ?? [:]
        
        if let commits = commits, (commitDict == nil ||
            commitDict3 == nil ||
            commitDict4 == nil ||
            commitDict5 == nil ||
            commitDict6 == nil ||
            commitDict7 == nil ||
            commitDict8 == nil ||
            commitDict9 == nil ||
            commitDict10 == nil ||
            commitDict11 == nil ||
            commitDict12 == nil) {
            
            for commit in commits {
                
                if commitDict == nil {
                    self.commitDict?[commit.objectHash] = commit
                }
                if commitDict3 == nil {
                    self.commitDict3?[String(commit.objectHash.prefix(3)) + "#"] = commit
                }
                if commitDict4 == nil {
                    self.commitDict4?[String(commit.objectHash.prefix(4)) + "#"] = commit
                }
                if commitDict5 == nil {
                    self.commitDict5?[String(commit.objectHash.prefix(5)) + "#"] = commit
                }
                if commitDict6 == nil {
                    self.commitDict6?[String(commit.objectHash.prefix(6)) + "#"] = commit
                }
                if commitDict7 == nil {
                    self.commitDict7?[String(commit.objectHash.prefix(7)) + "#"] = commit
                }
                if commitDict8 == nil {
                    self.commitDict8?[String(commit.objectHash.prefix(8)) + "#"] = commit
                }
                if commitDict9 == nil {
                    self.commitDict9?[String(commit.objectHash.prefix(9)) + "#"] = commit
                }
                if commitDict10 == nil {
                    self.commitDict10?[String(commit.objectHash.prefix(10)) + "#"] = commit
                }
                if commitDict11 == nil {
                    self.commitDict11?[String(commit.objectHash.prefix(11)) + "#"] = commit
                }
                if commitDict12 == nil {
                    self.commitDict12?[String(commit.objectHash.prefix(12)) + "#"] = commit
                }
                
            }
            
        }
    }
    
    public func commit(forShort hash: String) -> Commit? {
        if let commit =  self.commitDict3?["\(hash)#"] {
            return commit
        }
        if let commit =  self.commitDict4?["\(hash)#"] {
            return commit
        }
        if let commit =  self.commitDict5?["\(hash)#"] {
            return commit
        }
        if let commit =  self.commitDict6?["\(hash)#"] {
            return commit
        }
        if let commit =  self.commitDict7?["\(hash)#"] {
            return commit
        }
        if let commit =  self.commitDict8?["\(hash)#"] {
            return commit
        }
        if let commit =  self.commitDict9?["\(hash)#"] {
            return commit
        }
        if let commit =  self.commitDict10?["\(hash)#"] {
            return commit
        }
        if let commit =  self.commitDict11?["\(hash)#"] {
            return commit
        }
        if let commit =  self.commitDict12?["\(hash)#"] {
            return commit
        }
        return nil
    }
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
            let matches = result.find(rgx: #"commit\s([0-9a-fA-F]{40})(?:\s\(([^\n]+)\))?(?:\nMerge:\s([A-Fa-f0-9]{7,12})\s([A-Fa-f0-9]{7,12}))?\nAuthor:\s([^\n]+)\s<([^\n]*)>\nDate:\s+([^\n]+)\n([\s\S]*?)(?=commit\s[0-9a-fA-F]{40}(?:\s\([^\n]+\))?(?:\nMerge:\s([A-Fa-f0-9]{7,12})\s([A-Fa-f0-9]{7,12}))?\nAuthor:[^\n]+\nDate:[^\n]+|\Z)"#, options: .anchored)
            
            var commits = [Commit]()
            var commitsLong = [String: Commit]()
            
            var commits3 = [String: Commit]()
            var commits4 = [String: Commit]()
            var commits5 = [String: Commit]()
            var commits6 = [String: Commit]()
            var commits7 = [String: Commit]()
            var commits8 = [String: Commit]()
            var commits9 = [String: Commit]()
            var commits10 = [String: Commit]()
            var commits11 = [String: Commit]()
            var commits12 = [String: Commit]()
            
            for match in matches {
                let commit = try parseCommit(part: match)
                commits.append(commit)
                commitsLong[commit.objectHash] = commit
                commits3[String(commit.objectHash.prefix(3)) + "#"] = commit
                commits4[String(commit.objectHash.prefix(4)) + "#"] = commit
                commits5[String(commit.objectHash.prefix(5)) + "#"] = commit
                commits6[String(commit.objectHash.prefix(6)) + "#"] = commit
                commits7[String(commit.objectHash.prefix(7)) + "#"] = commit
                commits8[String(commit.objectHash.prefix(8)) + "#"] = commit
                commits9[String(commit.objectHash.prefix(9)) + "#"] = commit
                commits10[String(commit.objectHash.prefix(10)) + "#"] = commit
                commits11[String(commit.objectHash.prefix(11)) + "#"] = commit
                commits12[String(commit.objectHash.prefix(12)) + "#"] = commit
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
            objectHash: commitHash,
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
