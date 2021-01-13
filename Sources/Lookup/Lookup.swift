import UIKit

@dynamicMemberLookup
public struct Lookup {
    
    public var originValue: Any?
    public var dict: [String: Any?] = [:]
    
    public init?(_ dict: [String: Any?]) {
        if dict.count == 0 {
            return nil
        }
        
        self.originValue = dict
        self.dict = dict.compactMapValues({ $0 })
    }
    
    public init?(_ string: String?) {
        guard let string = string, string.count > 0 else {
            return nil
        }
        
        guard let stringData = string.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: stringData, options: .init()) as? [String: Any?]
        else {
            return nil
        }
        
        self.originValue = string
        self.dict = dict
    }
    
    public init?(_ any: Any?) {
        guard let any = any else {
            return nil
        }
        if let anyString = any as? String {
            self.init(anyString)
        } else if let anyDict = any as? [String: Any?] {
            self.init(anyDict)
        } else {
            self.init(mirrors(reflecting: any))
            self.originValue = any
        }
    }
    
    public subscript (dynamicMember dynamicMember: String) -> Value {
        if dynamicMember.contains(".") {
            var keys = dynamicMember.split(separator: ".").map({ String($0) })
            
            if let key = keys.first,
               let wrapperValue = dict[key, default: nil],
               let innerLookup = Lookup(wrapperValue) {
                keys.removeFirst()
                
                let newKey = keys.joined(separator: ".")
                return innerLookup[dynamicMember: newKey]
            }
            
            return Value(nil)
        }
        
        guard let wrapperValue = dict[dynamicMember, default: nil] else {
            return Value(nil)
        }
        return Value(wrapperValue)
    }
    
    public subscript (_ dynamicMember: String) -> Value {
        self[dynamicMember: dynamicMember]
    }
}

public extension Lookup {
    
    struct Value {
        public var value: Any?
        public init(_ value: Any?) {
            self.value = value
        }
    }
    
}

public extension Lookup.Value {
    
    var string: String? {
        value as? String
    }
    var stringValue: String {
        string!
    }
    
    var float: Float? {
        (string as NSString?)?.floatValue
    }
    var floatValue: Float {
        float!
    }
    
    var double: Double? {
        (string as NSString?)?.doubleValue
    }
    var doubleValue: Double {
        double!
    }
    
    var uInt: UInt? {
        if let int = int {
            return UInt(int)
        }
        return nil
    }
    var uIntValue: UInt {
        uInt!
    }
    
    var int: Int? {
        (string as NSString?)?.integerValue
    }
    var intValue: Int {
        int!
    }
    
    var int64: Int64? {
        if let value = (string as NSString?)?.integerValue {
            return Int64(value)
        }
        return nil
    }
    var int64Value: Int64 {
        int64!
    }
    
    var bool: Bool? {
        (string as NSString?)?.boolValue
    }
    var boolValue: Bool {
        (string! as NSString).boolValue
    }
    
    var dict: [String: Any]? {
        if let originDict = value as? [String: Any] {
            return originDict
        } else if let originString = value as? String,
                  let stringData = originString.data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: stringData, options: []) as? [String: Any]
        } else {
            return nil
        }
    }
    var dictValue: [String: Any] {
        dict!
    }
    
    var array: [Any]? {
        if let originArray = value as? [Any] {
            return originArray
        }
        return nil
    }
    var arrayValue: [Any] {
        array!
    }
}
