import UIKit

@dynamicMemberLookup
public struct Lookup: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var originValue: Any
    
    public var dict: [String: Any?] = [:]
    
    public var filteredDict: [String: Any] {
        dict.compactMapValues({ $0 })
    }
    
    public init?(_ dict: [String: Any?]) {
        if dict.count == 0 {
            return nil
        }
        
        self.originValue = dict
        self.dict = dict
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
    
    public var description: String {
        if let data = try? JSONSerialization.data(withJSONObject: originValue, options: .prettyPrinted),
           let prettyString = String(data: data, encoding: .utf8) {
            return prettyString
        }
        return "\(originValue)"
    }
    
    public var debugDescription: String {
        description
    }
}

public extension Lookup {
    
    struct Value {
        public var value: Any?
        
        init(_ value: Any?) {
            self.value = value
        }
    }
    
}

public extension Lookup.Value {
    
    // MARK: - String
    var string: String? {
        guard let v = value else {
            return nil
        }
        return "\(v)"
    }
    
    var stringValue: String {
        string!
    }
    
    /**
    /// A 32-bit floating point type.
    public typealias Float32 = Float
    
    /// A 64-bit floating point type.
    public typealias Float64 = Double
     */
    
    // MARK: - Float
    var float: Float? {
        (string as NSString?)?.floatValue
    }
    var floatValue: Float {
        float!
    }
    
    @available(iOS 14.0, *)
    var float16: Float16? {
        if let string = string {
            return .init(string)
        }
        return nil
    }
    @available(iOS 14.0, *)
    var float16Value: Float16 {
        float16!
    }
    
    // MARK: - Double
    var double: Double? {
        (string as NSString?)?.doubleValue
    }
    var doubleValue: Double {
        double!
    }
    
    // MARK: - UInt
    var uInt: UInt? {
        if let string = string {
            return .init(string)
        }
        return nil
    }
    var uIntValue: UInt {
        uInt!
    }
    
    var uInt16: UInt16? {
        if let string = string {
            return .init(string)
        }
        return nil
    }
    var uInt16Value: UInt16 {
        uInt16!
    }
    
    var uInt32: UInt32? {
        if let string = string {
            return .init(string)
        }
        return nil
    }
    var uInt32Value: UInt32 {
        uInt32!
    }
    
    var uInt64: UInt64? {
        if let string = string {
            return .init(string)
        }
        return nil
    }
    var uInt64Value: UInt64 {
        uInt64!
    }
    
    // MARK: - Int
    var int: Int? {
        (string as NSString?)?.integerValue
    }
    var intValue: Int {
        int!
    }
    
    var int16: Int16? {
        if let string = string {
            return .init(string)
        }
        return nil
    }
    var int16Value: Int16 {
        int16!
    }
    
    var int32: Int32? {
        (string as NSString?)?.intValue
    }
    var int32Value: Int32 {
        int32!
    }
    
    var int64: Int64? {
        (string as NSString?)?.longLongValue
    }
    var int64Value: Int64 {
        int64!
    }
    
    // MARK: - Bool
    var bool: Bool? {
        (string as NSString?)?.boolValue
    }
    var boolValue: Bool {
        (string! as NSString).boolValue
    }
    
    // MARK: - Dict
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
    
    // MARK: - Array
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
