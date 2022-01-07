#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - LookupModel (Model Helper)
public protocol LookupModel {
    var lookup: Lookup { get set }
}
public extension LookupModel {
    func member<T>(for name: String, type: T.Type = T.self) -> T? {
        let value = lookup[name]
        switch type {
        case is String.Type:
            return value.string as? T
        case is Float.Type:
            return value.float as? T
        case is Double.Type:
            return value.double as? T
        case is UInt.Type:
            return value.uInt as? T
        case is UInt16.Type:
            return value.uInt16 as? T
        case is UInt32.Type:
            return value.uInt32 as? T
        case is UInt64.Type:
            return value.uInt64 as?  T
        case is Int.Type:
            return value.int as? T
        case is Int16.Type:
            return value.int16 as? T
        case is Int32.Type:
            return value.int32 as? T
        case is Int64.Type:
            return value.int64 as? T
        case is Bool.Type:
            return value.bool as? T
        case is Array<Any>.Type:
            return value.array as? T
        case is Dictionary<String, Any>.Type:
            return value.dict as? T
        default:
            return value.rawValue as? T
        }
    }
}

// MARK: - extension Array Helper merging multi lookup into one lookup
public extension Array where Element == Lookup {
    
    /// Merging multi rawDict into one
    /// - Parameter uniquingKeysWith: uniquing keys with conflict
    /// - Returns: Merged `Lookup`
    func merging(uniquingKeysWith: (Any, Any) -> Any) -> Lookup {
        let dictLookups = self.compactMap({ $0.dict })
        var temp: [String: Any] = [:]
        for value in dictLookups {
            temp.merge(value, uniquingKeysWith: uniquingKeysWith)
        }
        return Lookup(temp)
    }
}

// MARK: - Helper for String
fileprivate extension String {
    var isPurnInt: Bool {
        let scan: Scanner = Scanner(string: self)
        var val: Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }
}

// MARK: Unwrap
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
        return array.map(unwrap)
        
    default:
        return object
    }
}

// MARK: - Lookup
@dynamicMemberLookup
public struct Lookup: CustomStringConvertible {
    
    public enum RawType {
        case none
        case dict
        case array
        case object
        case number
        case string
    }
    
    fileprivate private(set) var object: Any
    public var rawValue: Any { object }
    
    fileprivate let rawType: RawType
    fileprivate private(set) var rawDict: [String: Any] = [:]
    fileprivate private(set) var rawArray: [Any] = []
    fileprivate private(set) var rawString: String = ""
    fileprivate private(set) var rawNumber: NSNumber = .init()
    
    private init(jsonObject: Any) {
        self.object = jsonObject
        
        switch jsonObject {
        case Optional<Any>.none:
            self.rawType = .none
        case _ as NSNull:
            self.rawType = .none
            
        default:
            switch unwrap(object) {
            case let number as NSNumber:
                self.rawNumber = number
                self.rawType = .number
                
            case let str as String:
                self.rawString = str
                self.rawType = .string
                
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
    
    /// Support JSON-Data, String of JSON, Array, Dictionary, Struct object and Class object
    public init(_ object: Any) {
        switch object {
        case let str as String:
            if JSONSerialization.isValidJSONObject(object)  {
                do {
                    try self.init(jsonString: str)
                } catch {
                    self.init(jsonObject: NSNull())
                }
            } else {
                self.init(jsonObject: object)
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
    
    
    public subscript (dynamicMember dynamicMember: String) -> Lookup {
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
                case .array, .string:
                    if key.isPurnInt, let index = Int(key) {
                        keys.removeFirst()
                        
                        let newKey = keys.joined(separator: ".")
                        return self[index][dynamicMember: newKey]
                    }
                    return .null
                default:
                    return .null
                }
            }
            return .null
        }
        
        switch rawType {
        case .dict, .object:
            return Lookup(rawDict[dynamicMember, default: NSNull()])
        case .array, .string:
            if dynamicMember.isPurnInt,
                let index = Int(dynamicMember)
            {
                return self[index]
            }
            return .null
        default:
            return .null
        }
    }
    
    public subscript (_ dynamicMember: String) -> Lookup {
        self[dynamicMember: dynamicMember]
    }
    
    public subscript (_ memberIndex: Int) -> Lookup {
        switch rawType {
        case .string:
            if let convertedArray = array, memberIndex < convertedArray.count {
                return Lookup(convertedArray[memberIndex])
            }
            return .null
        case .array:
            if memberIndex > rawArray.count {
                return .null
            }
            return Lookup(rawArray[memberIndex])
        default:
            return .null
        }
    }
    
    public var description: String {
        var desc = ""
        switch rawType {
        case .dict, .object:
            desc = rawDict.description
        case .array:
            desc = rawArray.description
        case .number:
            desc = "\(rawNumber)"
        case .string:
            desc = "\(object)"
        case .none:
            desc = "nil"
        }
        return "{ rawType: \(rawType), description: \(desc) }"
    }
    
    fileprivate static var null: Lookup { Lookup(NSNull()) }
}

// MARK: - Convert
public extension Lookup {
    
    var isNone: Bool {
        rawType == .none
    }
    
    var isSome: Bool {
        !isNone
    }
    
    // MARK: - String
    var string: String? {
        switch rawType {
        case .number:
            return "\(rawNumber)"
        case .string:
            return rawString
        default:
            return nil
        }
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
    
    #if !targetEnvironment(macCatalyst) && os(iOS)
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
        switch rawType {
        case .dict:
            return rawDict
        case .string:
            if let originString = object as? String,
                let stringData = originString.data(using: .utf8)
            {
                    return try? JSONSerialization.jsonObject(with: stringData, options: []) as? [String: Any]
            }
            return nil
        default:
            return nil
        }
    }
    var dictValue: [String: Any] {
        dict!
    }
    
    // MARK: - Array
    var array: [Any]? {
        switch rawType {
        case .array:
            return rawArray
        case .string:
            if let originString = object as? String,
               let stringData = originString.data(using: .utf8)
            {
                return try? JSONSerialization.jsonObject(with: stringData, options: []) as? [Any]
            }
            return nil
        default:
            return nil
        }
    }
    var arrayValue: [Any] {
        array!
    }
}
