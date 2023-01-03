//
//  String+Date.swift
//  
//
//  Created by Artur Hellmann on 03.01.23.
//

import Foundation

public extension String {
    public func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}
