//
//  Created by iWw on 2021/1/13.
//

import UIKit

extension Dictionary {
    /// Merges the dictionary with dictionaries passed. The latter dictionaries will override
    /// values of the keys that are already set
    ///
    /// - parameter dictionaries: A comma seperated list of dictionaries
    mutating func merge<K, V>(dictionaries: Dictionary<K, V>...) {
        for dict in dictionaries {
            for (key, value) in dict {
                self.updateValue(value as! Value, forKey: key as! Key)
            }
        }
    }
}

func canMirrorInto(_ reflecting: Any?) -> Bool {
    guard let ref = reflecting else { return false }
    let mirror = Mirror(reflecting: ref)
    guard let displayStyle = mirror.displayStyle else { return false }
    return displayStyle == .class || displayStyle == .struct
}

public func mirrors(reflecting: Any?, _ each: ((_: String?, _: Any) -> Void)? = nil) -> [String: Any] {
    guard let reflecting = reflecting else { return [:] }
    
    var map: [String: Any] = [:]
    
    let mirror = Mirror(reflecting: reflecting)
    for child in mirror.children {
        if canMirrorInto(child.value) {
            map.merge(dictionaries: mirrors(reflecting: child.value, each))
            continue
        }
        if let label = child.label, label.count > 0 {
            map[label] = child.value
        }
        each?(child.label, child.value)
    }
    
    var superMirror = mirror.superclassMirror
    while superMirror != nil {
        for child in superMirror!.children {
            if canMirrorInto(child.value) {
                map.merge(dictionaries: mirrors(reflecting: child.value, each))
                continue
            }
            if let label = child.label, label.count > 0 {
                map[label] = child.value
            }
            each?(child.label, child.value)
        }
        superMirror = superMirror?.superclassMirror
    }
    return map
}

