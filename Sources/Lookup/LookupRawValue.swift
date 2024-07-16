//
//  Created by iww on 2022/4/6.
//

import Foundation

public protocol LookupRawValue {
    var lookupRawValue: Any { get }
}

extension Date: LookupRawValue {
    public var lookupRawValue: Any {
        self.timeIntervalSince1970
    }
}

extension UUID: LookupRawValue {
    public var lookupRawValue: Any {
        self.uuidString
    }
}
