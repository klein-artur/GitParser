//
//  Commit.swift
//  
//
//  Created by Artur Hellmann on 03.01.23.
//

import Foundation

public class Commit: HasHash {
    public var hash: String
    public var message: String
    public var author: Person
    public var date: Date
    public var branches: [String]
    public var tags: [String]
    
    init(
        hash: String,
        message: String,
        author: Person,
        date: Date,
        branches: [String],
        tags: [String]
    ) {
        self.hash = hash
        self.message = message
        self.author = author
        self.date = date
        self.branches = branches
        self.tags = tags
    }
}
