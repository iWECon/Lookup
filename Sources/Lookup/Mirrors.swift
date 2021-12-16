//
//  Created by iWw on 2021/1/13.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

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
        if let label = child.label, label.count > 0 {
            map[label] = canMirrorInto(child.value) ? mirrors(reflecting: child.value, each) : child.value
        }
        each?(child.label, child.value)
    }
    
    var superMirror = mirror.superclassMirror
    while superMirror != nil {
        for child in superMirror!.children {
            if let label = child.label, label.count > 0 {
                map[label] = canMirrorInto(child.value) ? mirrors(reflecting: child.value, each) : child.value
            }
            each?(child.label, child.value)
        }
        superMirror = superMirror?.superclassMirror
    }
    return map
}

