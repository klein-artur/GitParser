//
//  HasHash.swift
//  
//
//  Created by Artur Hellmann on 03.01.23.
//

import Foundation

/// Represents objects that have a hash.
public protocol HasHash: Hashable {
    var objectHash: String { get }
    var shortHash: String { get }
}

public extension HasHash {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(objectHash)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.objectHash == rhs.objectHash
    }
    
}
