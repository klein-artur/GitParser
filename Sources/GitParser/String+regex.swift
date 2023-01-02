//
//  String+regex.swift
//  
//
//  Created by Artur Hellmann on 30.12.22.
//

import Foundation

struct RgxResult {
    private let textCheckingResult: NSTextCheckingResult
    private let baseString: String
    
    init(_ result: NSTextCheckingResult, _ baseString: String) {
        self.textCheckingResult = result
        self.baseString = baseString
    }
}

extension String {
    var rgx: NSRegularExpression? {
        try? NSRegularExpression(pattern: self, options: [])
    }
    
    func find(rgx pattern: String) -> [RgxResult] {
        pattern.rgx?.matches(in: self, options: [], range: 0<!>self.count)
            .map {
                RgxResult(
                    $0,
                    self
                )
            } ?? []
    }
    
    func replace(rgx pattern: String, with template: String) -> String {
        let mutatingString = NSMutableString(string: self)
        
        pattern.rgx?.replaceMatches(in: mutatingString, options: [], range: 0<!>self.count, withTemplate: template)
        
        return mutatingString as String
    }
}

extension RgxResult {
    subscript(index: Int) -> String? {
        guard textCheckingResult.range(at: index).location != NSNotFound else {
            return nil
        }
        return String(baseString[Range(textCheckingResult.range(at: index), in: baseString)!])
    }
}

precedencegroup SquareSumOperatorPrecedence {
    lowerThan: MultiplicationPrecedence
    higherThan: AdditionPrecedence
    associativity: left
    assignment: false
}

infix operator <!>: SquareSumOperatorPrecedence

extension Int {
    static func <!> (left: Int, right: Int) -> NSRange {
        NSRange(location: left, length: right - left)
    }
}
