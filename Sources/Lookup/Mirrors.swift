//
//  Created by iWw on 2021/1/13.
//

import Foundation

func canMirrorInto(_ reflecting: Any?) -> Bool {
    if let _ = reflecting as? LookupRawValue {
        return false
    }
    guard let ref = reflecting else { return false }
    let mirror = Mirror(reflecting: ref)
    guard let displayStyle = mirror.displayStyle else { return false }
    return (displayStyle == .class || displayStyle == .struct)
}

func mirrorValue(_ value: Any) -> Any {
    if let lookupRawValue = value as? LookupRawValue {
        return lookupRawValue.lookupRawValue
    }
    let mirror = Mirror(reflecting: value)
    guard mirror.displayStyle == .enum else {
        return value
    }
    return "\(value)"
}

public func mirrors(reflecting: Any?, _ each: ((_: String?, _: Any) -> Void)? = nil) -> [String: Any] {
    guard let reflecting = reflecting else { return [:] }
    
    var map: [String: Any] = [:]
    
    let mirror = Mirror(reflecting: reflecting)
    for child in mirror.children {
        if let label = child.label, !label.isEmpty {
            map[label] = canMirrorInto(child.value) ? mirrors(reflecting: child.value, each) : mirrorValue(child.value)
        }
        each?(child.label, child.value)
    }
    
    var superMirror = mirror.superclassMirror
    while superMirror != nil {
        for child in superMirror!.children {
            if let label = child.label, !label.isEmpty {
                map[label] = canMirrorInto(child.value) ? mirrors(reflecting: child.value, each) : mirrorValue(child.value)
            }
            each?(child.label, child.value)
        }
        superMirror = superMirror?.superclassMirror
    }
    return map
}

