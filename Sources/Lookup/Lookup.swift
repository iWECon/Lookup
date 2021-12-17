#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension Array where Element == Lookup {
    
    /// Merging multi rawDict into one
    /// - Parameter uniquingKeysWith: uniquing keys with conflict
    /// - Returns: Merged `Lookup`
    func merging(uniquingKeysWith: (Any, Any) -> Any) -> Lookup {
        let dictLookups = self.filter({ $0.rawType == .dict })
        var temp: [String: Any] = [:]
        for value in dictLookups {
            temp.merge(value.rawDict, uniquingKeysWith: uniquingKeysWith)
        }
        return Lookup(temp)
    }
}

fileprivate extension String {
    func between(left: String, _ right: String) -> String? {
        return (range(of: left)?.upperBound).flatMap { substringFrom in
            (range(of: right, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

fileprivate func unwrap(_ object: Any) -> Any {
    switch object {
    case let number as NSNumber:
        return number
    case let str as String:
        return str
    case _ as NSNull:
        return NSNull()
    case nil:
        return NSNull()
        
    case let dictionary as [String: Any]:
        var d = dictionary
        dictionary.forEach { pair in
            d[pair.key] = unwrap(pair.value)
        }
        return d
        
    case let array as [Any]:
        return array
        
    default:
        return object
    }
}

@dynamicMemberLookup
public struct Lookup: CustomStringConvertible {
    
    public enum RawType {
        case none
        case dict
        case array
        case object
    }
    
    public private(set) var object: Any
    
    public let rawType: RawType
    public private(set) var rawDict: [String: Any] = [:]
    public private(set) var rawArray: [Any] = []
    
    private init(jsonObject: Any) {
        self.object = jsonObject
        
        switch unwrap(object) {
        case let dictionry as [String: Any]:
            self.rawDict = dictionry
            self.rawType = .dict
            
        case let array as [Any]:
            self.rawArray = array
            self.rawType = .array
            
        case _ as AnyObject:
            self.rawDict = mirrors(reflecting: jsonObject)
            self.rawType = .object
            
        default:
            self.rawType = .none
        }
    }
    
    private init(data: Data, options opt: JSONSerialization.ReadingOptions = []) throws {
        let object: Any = try JSONSerialization.jsonObject(with: data, options: opt)
        self.init(jsonObject: object)
    }
    
    private init(jsonString: String) throws {
        guard let stringData = jsonString.data(using: .utf8) else {
            fatalError("It's not a json string: \(jsonString)")
        }
        try self.init(data: stringData)
    }
    
    public init(_ object: Any) {
        switch object {
        case let str as String:
            do {
                try self.init(jsonString: str)
            } catch {
                self.init(jsonObject: NSNull())
            }
        case let data as Data:
            do {
                try self.init(data: data)
            } catch {
                self.init(jsonObject: NSNull())
            }
        default:
            self.init(jsonObject: object)
        }
    }
    
    
    public subscript (dynamicMember dynamicMember: String) -> Value {
        if dynamicMember.contains(".") {
            var keys = dynamicMember.components(separatedBy: ".")
            
            if let key = keys.first {
                switch rawType {
                case .none:
                    return .null
                case .dict, .object:
                    let value = rawDict[key, default: NSNull()]
                    let innerLookup = Lookup(value)
                    keys.removeFirst()
                    
                    let newKey = keys.joined(separator: ".")
                    return innerLookup[dynamicMember: newKey]
                case .array:
                    if let indexStringKey = key.between(left: "[", "]"),
                        let intKey = Int(indexStringKey),
                       intKey < rawArray.count {
                        let value = rawArray[intKey]
                        let innerLookup = Lookup(value)
                        keys.removeFirst()
                        
                        let newKey = keys.joined(separator: ".")
                        return innerLookup[dynamicMember: newKey]
                    }
                    return .null
                }
            }
            return Value.null
        }
        
        switch rawType {
        case .dict, .object:
            return Value(rawDict[dynamicMember, default: NSNull()])
        default:
            return .null
        }
    }
    
    public subscript (_ dynamicMember: String) -> Value {
        self[dynamicMember: dynamicMember]
    }
    
    public subscript (_ memberIndex: Int) -> Value {
        switch rawType {
        case .array:
            if memberIndex > rawArray.count {
                return .null
            }
            return Value(rawArray[memberIndex])
        default:
            return .null
        }
    }
    
    public var description: String {
        switch rawType {
        case .none:
            return "\(object)"
        case .dict, .object:
            return rawDict.description
        case .array:
            return rawArray.description
        }
    }
}

public extension Lookup {
    
    struct Value: CustomStringConvertible {
        private let value: Any
        
        init(_ value: Any) {
            self.value = unwrap(value)
        }
        
        public var description: String {
            switch rawValue {
            case .some(let v):
                return "\(v)"
            case .none:
                return "nil"
            }
        }
        
        public var rawValue: Any? {
            switch value {
            case _ as NSNull:
                return nil
            case nil:
                return nil
            default:
                return value
            }
        }
        
        public var isNil: Bool {
            rawValue == nil
        }
        public var isSome: Bool {
            !isNil
        }
        
        fileprivate static var null: Value { Value(NSNull()) }
    }
    
}

public extension Lookup.Value {
    
    // MARK: - String
    var string: String? {
        guard let v = rawValue else {
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
    
    #if os(iOS)
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
    #endif
    
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
        if let originDict = rawValue as? [String: Any] {
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
        if let originArray = rawValue as? [Any] {
            return originArray
        }
        return nil
    }
    var arrayValue: [Any] {
        array!
    }
}
