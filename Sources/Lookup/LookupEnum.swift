//
//  File.swift
//  
//
//  Created by iww on 2022/4/6.
//

import Foundation

/// LookupEnum
///
/// Default implemention `Int` and `String`
public protocol LookupEnum {
    var lookupRawValue: Any { get }
}

extension LookupEnum where Self: RawRepresentable, Self.RawValue == Int {
    var lookupRawValue: Any {
        self.rawValue
    }
}

extension LookupEnum where Self: RawRepresentable, Self.RawValue == String {
    var lookupRawValue: Any {
        self.rawValue
    }
}
