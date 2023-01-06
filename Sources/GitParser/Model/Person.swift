//
//  Person.swift
//  
//
//  Created by Artur Hellmann on 03.01.23.
//

import Foundation

/// Representing a Person like the Author.
public struct Person {
    public let name: String
    public let email: String
    
    public init(name: String, email: String) {
        self.name = name
        self.email = email
    }
}
