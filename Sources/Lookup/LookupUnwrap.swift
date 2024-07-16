//
//  File.swift
//  
//
//  Created by i on 2024/7/16.
//

import Foundation

public protocol LookupUnwrap {
    
    func lookupUnwrap(key: String, value: Any) -> Any?
}

extension LookupUnwrap {
    public func lookupUnwrap(key: String, value: Any) -> Any? {
        value
    }
}
