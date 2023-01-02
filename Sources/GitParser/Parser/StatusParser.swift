//
//  StatusParser.swift
//  
//
//  Created by Artur Hellmann on 30.12.22.
//

import Foundation
import Combine

/// Representing a `git status` command result
public struct GitStatus: ParseResult {
    
    public var originalOutput: String
    
    public let branch: Branch
    public var stagedChanges: [Change] = []
    public var unstagedChanges: [Change] = []
    public var untrackedChanges: [Change] = []
    public var unmergedChanges: [Change] = []
    
    public var status: Status {
        if !branch.upToDate {
            return .unclean
        }
        
        if !stagedChanges.isEmpty || !unstagedChanges.isEmpty || !untrackedChanges.isEmpty || !unmergedChanges.isEmpty {
            return .unclean
        }
        
        return .clean
    }
    
    /// A status the git repo can have.
    public enum Status {
        
        /// Repo is clean and ready to go.
        case clean
        
        /// Repo has changes.
        case unclean
    }
}

public struct Change {
    public let path: String
    public let kind: Kind
    public let state: State
    
    public enum Kind: String {
        case modified = "modified"
        case deleted = "deleted"
        case newFile = "new file"
        case bothAdded = "both added"
        case bothModified = "both modified"
    }
    
    public enum State {
        case staged
        case unstaged
        case untracked
        case unmerged
    }
}

public class StatusParser: GitParser, Parser {
    
    public typealias Success = GitStatus
    
    override public init() {
        super.init()
    }
    
    public func parse(result: String) -> Result<Success, ParseError> {
        if let error = super.parseForIssues(result: result) {
            return .failure(error)
        }
        
        var branchName = result.find(rgx: "On branch (.*)").first?[1]
        var detached = false
        
        if let head = result.find(rgx: "(HEAD) detached").first?[1] {
            branchName = head
            detached = true
        }
        
        guard let branchName = branchName else {
            return .failure(.noBranchNameFound)
        }
        
        var behind = 0
        var ahead = 0
        
        if let isBehind = Int(result.find(rgx: "behind '.*' by ([0-9]+) commit").first?[1] ?? "0") {
            behind = isBehind
        }
        
        if let isAhead = Int(result.find(rgx: "ahead of '.*' by ([0-9]+) commit").first?[1] ?? "0") {
            ahead = isAhead
        }
        
        if let divergedResult = result.find(rgx: "and have ([0-9]+) and ([0-9]+) different").first, let foundAhead = divergedResult[1], let foundBehind = divergedResult[2] {
            ahead = Int(foundAhead) ?? 0
            behind = Int(foundBehind) ?? 0
        }
        
        var upstream: Branch?
        if let upstreamName = result.find(rgx: "(?:with|behind|and|of) '(.*)'").first?[1] {
            upstream = Branch(name: upstreamName, isLocal: false)
        }
        
        return .success(
            GitStatus(
                originalOutput: result,
                branch: Branch(
                    name: branchName,
                    isLocal: true,
                    behind: behind,
                    ahead: ahead,
                    upstream: upstream,
                    detached: detached
                ),
                stagedChanges: getStagedChanged(in: result),
                unstagedChanges: getUnstagedChanges(in: result),
                untrackedChanges: getUntrackedFiles(in: result),
                unmergedChanges: getUnmergedChanges(in: result)
            )
        )
    }
    
    private func getStagedChanged(in result: String) -> [Change] {
        guard let stagedGroup = result.find(rgx: #"Changes to be committed:\n.*\n(?:\s*(?:modified|deleted|new file):\s*.*\n?)+"#).first?[0] else {
            return []
        }
        
        return findChangesIn(group: stagedGroup, state: .staged)
    }
    
    private func getUnstagedChanges(in result: String) -> [Change] {
        guard let unstagedGroup = result.find(rgx: #"Changes not staged for commit:\n.*\n.*\n(?:\s*(?:modified|deleted|new file):\s*.*\n?)+"#).first?[0] else {
            return []
        }
        
        return findChangesIn(group: unstagedGroup, state: .unstaged)
    }
    
    private func getUnmergedChanges(in result: String) -> [Change] {
        guard let unmergedGroup = result.find(rgx: #"Unmerged paths:\n.*\n.*\n(?:\s*(?:both added|both modified):\s*.*\n?)+"#).first?[0] else {
            return []
        }
        
        return findChangesIn(group: unmergedGroup, state: .unmerged)
    }
    
    private func getUntrackedFiles(in result: String) -> [Change] {
        guard let untrackedGroup = result.find(rgx: #"Untracked files:\n\s+\(use "git add <file>\.\.\." to include in what will be committed\)\n([\s\S]++)"#).first?[1] else {
            return []
        }
        
        return untrackedGroup.find(rgx: #"\s+([^(\n")]*)"#)
            .map { foundChange in
                Change(
                    path: foundChange[1]!,
                    kind: .newFile,
                    state: .untracked
                )
            }
    }
    
    private func findChangesIn(group: String, state: Change.State) -> [Change] {
        return group.find(rgx: #"\s*(modified|deleted|new file|both added|both modified):\s*(.*)"#)
            .map { foundChange in
                Change(
                    path: foundChange[2]!,
                    kind: Change.Kind(rawValue: foundChange[1]!)!,
                    state: state
                )
            }
    }
}

/// Tests
public extension GitStatus {
    public static func getTestStatus() -> GitStatus {
        GitStatus(
            originalOutput: "",
            branch: Branch(
                name: "some_very_long/branch_name",
                isLocal: true,
                behind: 15,
                ahead: 10,
                upstream: Branch(name: "origin/some_very_very_very_very_very_long/branch_name", isLocal: false),
                detached: false
            ),
            stagedChanges: [Change(path: "some/path.file", kind: .newFile, state: .staged)],
            unstagedChanges: [Change(path: "some/other/path.file", kind: .newFile, state: .unstaged)],
            untrackedChanges: [Change(path: "some/new/path.file", kind: .newFile, state: .untracked)],
            unmergedChanges: [Change(path: "some/unmerged/path.file", kind: .bothAdded, state: .unmerged)]
        )
    }
}
