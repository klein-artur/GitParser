//
//  Branch.swift
//  
//
//  Created by Artur Hellmann on 30.12.22.
//

import Foundation

public class Branch {
    public let name: String
    public let isLocal: Bool
    public let behind: Int
    public let ahead: Int
    public let upstream: Branch?
    public let detached: Bool
    
    public var upToDate: Bool {
        return behind == 0 && ahead == 0
    }
    
    init(
        name: String,
        isLocal: Bool,
        behind: Int = 0,
        ahead: Int = 0,
        upstream: Branch? = nil,
        detached: Bool = false
    ) {
        self.name = name
        self.isLocal = isLocal
        self.behind = behind
        self.ahead = ahead
        self.upstream = upstream
        self.detached = detached
    }
}
