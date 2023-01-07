//
//  Commit.swift
//  
//
//  Created by Artur Hellmann on 03.01.23.
//

import Foundation

public class Commit: HasHash {
    public var objectHash: String
    public var shortHash: String
    public var subject: String
    public var message: String
    public var author: Person
    public var authorDate: Date
    public var committer: Person
    public var committerDate: Date
    public var branches: [String]
    public var tags: [String]
    public var parents: [String]
    
    public init(
        objectHash: String,
        shortHash: String,
        subject: String,
        message: String,
        author: Person,
        authorDate: Date,
        committer: Person,
        committerDate: Date,
        branches: [String],
        tags: [String],
        parents: [String]
    ) {
        self.objectHash = objectHash
        self.shortHash = shortHash
        self.subject = subject
        self.message = message
        self.author = author
        self.authorDate = authorDate
        self.committer = committer
        self.committerDate = committerDate
        self.branches = branches
        self.tags = tags
        self.parents = parents
    }
}
