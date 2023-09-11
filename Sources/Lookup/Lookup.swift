import Foundation

extension Array {
    var countIndex: Int {
        count - 1
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
fileprivate func unwrap(_ object: Any?) -> Any {
    switch object {
    case let lookup as Lookup:
        return unwrap(lookup.object)
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
        return object ?? NSNull()
    }
}

// MARK: - Lookup
@dynamicMemberLookup
public struct Lookup: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    
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
    fileprivate private(set) var rawNumber: NSNumber = 0
    
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
    
    private init(data: Data, options opt: JSONSerialization.ReadingOptions = []) {
        do {
            let object: Any = try JSONSerialization.jsonObject(with: data, options: opt)
            self.init(jsonObject: object)
        } catch let error as NSError {
            // Code=3840 "JSON text did not start with array or object and option to allow fragments not set. around line 1, column 0."
            if error.code == 3840, let str = String(data: data, encoding: .utf8) { // try to initialize using a string
                self.init(jsonObject: str)
            } else {
                self.init(jsonObject: NSNull())
            }
        }
    }
    
    private init(jsonString: String) {
        guard let stringData = jsonString.data(using: .utf8) else {
            self.init(jsonObject: NSNull())
            return
        }
        self.init(data: stringData)
    }
    
    /// Support `JSON-Data`, `String-Data`, `String of JSON`, `Array`, `Dictionary`, `Struct object` and `Class object`
    public init(_ object: Any) {
        switch object {
        case let str as String:
            self.init(jsonString: str)
        case let data as Data:
            self.init(data: data)
        default:
            self.init(jsonObject: object)
        }
    }
    
    // Resolve build warning:
    // heterogeneous collection literal could only be inferred to '[String : Any]'; add explicit type annotation if this is intentional
    public init(_ anyDictionary: [String: Any]) {
        self.init(anyDictionary as Any)
    }
    
    private func makeLookup(from dynamicMember: String) -> Lookup {
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
    
    // TODO: dynamicMember change
    private mutating func setNewValue(for dynamicMember: String, value: Lookup) {
        switch rawType {
        case .none:
            break
        case .dict:
            rawDict[dynamicMember] = value.rawValue
        case .array:
            switch value.rawType {
            case .array:
                rawArray = value.rawArray
            default:
                break
            }
        case .object:
            break
        case .number:
            break
        case .string:
            break
        }
    }
    
    public subscript (dynamicMember dynamicMember: String) -> Lookup {
        get {
            makeLookup(from: dynamicMember)
        }
        set {
            setNewValue(for: dynamicMember, value: newValue)
        }
    }
    
    public subscript (_ dynamicMember: String) -> Lookup {
        get {
            self[dynamicMember: dynamicMember]
        }
        set {
            self[dynamicMember: dynamicMember] = newValue
        }
    }
    
    public subscript (_ memberIndex: Int) -> Lookup {
        switch rawType {
        case .string:
            if let convertedArray = array, memberIndex < convertedArray.count {
                return Lookup(convertedArray[memberIndex])
            }
            return .null
        case .array:
            if memberIndex > rawArray.countIndex {
                return .null
            }
            return Lookup(rawArray[memberIndex])
        default:
            return .null
        }
    }
    
    private func jsonToPrettyString(value: Any) -> String? {
        if JSONSerialization.isValidJSONObject(value),
           let data = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted),
           let str = String(data: data, encoding: .utf8)
        {
            return str
        }
        return nil
    }
    
    private func castValueToString(value: Any) -> String {
        if let str = jsonToPrettyString(value: value) {
            return str
        }
        // map to string
        switch value {
        case let dict as Dictionary<String, Any>:
            let strDict = Dictionary(uniqueKeysWithValues: dict.map { (key: String, value: Any) in
                (key, "\(value)")
            })
            return jsonToPrettyString(value: strDict) ?? "\(strDict)"
            
        case let arr as [Any]:
            return jsonToPrettyString(value: arr) ?? "\(arr)"
            
        default:
            return "\(value)"
        }
    }
    
    public var description: String {
        let desc: String
        switch rawType {
        case .dict, .object:
            desc = castValueToString(value: rawDict)
        case .array:
            desc = castValueToString(value: rawArray)
        case .number:
            desc = "\(rawNumber)"
        case .string:
            desc = "\(object)"
        case .none:
            desc = "nil"
        }
        return desc
    }
    
    public var debugDescription: String { description }
    
    fileprivate static var null: Lookup { Lookup(NSNull()) }
    
    fileprivate mutating func merge(other: Lookup) {
        switch (self.rawType, other.rawType) {
        case (.dict, .dict):
            self.rawDict.merge(other.rawDict, uniquingKeysWith: { $1 })
        case (.array, .array):
            self.rawArray += other.rawArray
        default:
            break
        }
    }
}

extension Lookup: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Any
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(jsonObject: elements)
    }
}

extension Lookup: ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = Any
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(jsonObject: Dictionary(uniqueKeysWithValues: elements))
    }
}

extension Lookup: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(jsonObject: value)
    }
}

extension Lookup: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(jsonObject: value)
    }
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
    
    var dictLookup: Lookup {
        switch rawType {
        case .dict:
            return Lookup(rawDict)
        case .string:
            if let originString = object as? String,
               let stringData = originString.data(using: .utf8),
               let _dict = try? JSONSerialization.jsonObject(with: stringData, options: []) as? [String: Any]
            {
                return Lookup(_dict)
            }
            return .null
        default:
            return .null
        }
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
    
    var arrayLookup: [Lookup] {
        switch rawType {
        case .array:
            return rawArray.map { Lookup($0) }
        case .string:
            if let originString = object as? String,
               let stringData = originString.data(using: .utf8),
               let _array = try? JSONSerialization.jsonObject(with: stringData, options: []) as? [Any]
            {
                return _array.map { Lookup($0) }
            }
            return []
        default:
            return []
        }
    }
    
    var lookup: Lookup {
        Lookup(rawValue)
    }
    
    /// Available on `array` and `dict`
    var jsonData: Data? {
        switch rawType {
        case .array:
            return try? JSONSerialization.data(withJSONObject: rawArray)
        case .dict:
            return try? JSONSerialization.data(withJSONObject: rawDict)
        default:
            return nil
        }
    }
}


// MARK: - Operator
public func + (lhs: Lookup, rhs: Lookup) -> Lookup {
    switch (lhs.rawType, rhs.rawType) {
    case (.dict, .dict):
        let lhsRawDict = lhs.rawDict
        return Lookup(lhsRawDict.merging(rhs.rawDict, uniquingKeysWith: { $1 }))
    case (.array, .array):
        return Lookup(lhs.rawArray + rhs.rawArray)
    default:
        return .null
    }
}

public func += (lhs: inout Lookup, rhs: Lookup) {
    lhs.merge(other: rhs)
}

// MARK: - Codable
extension Lookup: Codable {
    
    private var codableDictionary: [String: Lookup]? {
        if rawType == .dict {
            var d = [String: Lookup](minimumCapacity: rawDict.count)
            rawDict.forEach { pair in
                d[pair.key] = Lookup(pair.value)
            }
            return d
        }
        return nil
    }
    
    private var codableArray: [Lookup]? {
        rawType == .array ? rawArray.map { Lookup($0) } : nil
    }
    
    private static var codableTypes: [Codable.Type] {
        [
            Bool.self,
            Int.self, Int8.self, Int16.self, Int32.self, Int64.self,
            UInt.self, UInt8.self, UInt16.self, UInt32.self, UInt64.self,
            Double.self,
            String.self,
            [Lookup].self,
            [String: Lookup].self
        ]
    }
    public init(from decoder: Decoder) throws {
        var object: Any?

        if let container = try? decoder.singleValueContainer(), !container.decodeNil() {
            for type in Lookup.codableTypes {
                if object != nil {
                    break
                }
                // try to decode value
                switch type {
                case let stringType as String.Type:
                    object = try? container.decode(stringType)
                case let jsonValueArrayType as [Lookup].Type:
                    object = try? container.decode(jsonValueArrayType)
                case let jsonValueDictType as [String: Lookup].Type:
                    object = try? container.decode(jsonValueDictType)
                case let boolType as Bool.Type:
                    object = try? container.decode(boolType)
                case let doubleType as Double.Type:
                    object = try? container.decode(doubleType)
                case let uintType as UInt.Type:
                    object = try? container.decode(uintType)
                case let uint64Type as UInt64.Type:
                    object = try? container.decode(uint64Type)
                case let uint32Type as UInt32.Type:
                    object = try? container.decode(uint32Type)
                case let uint16Type as UInt16.Type:
                    object = try? container.decode(uint16Type)
                case let uint8Type as UInt8.Type:
                    object = try? container.decode(uint8Type)
                case let intType as Int.Type:
                    object = try? container.decode(intType)
                case let int64Type as Int64.Type:
                    object = try? container.decode(int64Type)
                case let int32Type as Int32.Type:
                    object = try? container.decode(int32Type)
                case let int16Type as Int16.Type:
                    object = try? container.decode(int16Type)
                case let int8Type as Int8.Type:
                    object = try? container.decode(int8Type)
                default:
                    break
                }
            }
        }
        self.init(object ?? NSNull())
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if object is NSNull {
            try container.encodeNil()
            return
        }
        switch object {
        case let intValue as Int:
            try container.encode(intValue)
        case let int8Value as Int8:
            try container.encode(int8Value)
        case let int16Value as Int16:
            try container.encode(int16Value)
        case let int32Value as Int32:
            try container.encode(int32Value)
        case let int64Value as Int64:
            try container.encode(int64Value)
        case let uintValue as UInt:
            try container.encode(uintValue)
        case let uint8Value as UInt8:
            try container.encode(uint8Value)
        case let uint16Value as UInt16:
            try container.encode(uint16Value)
        case let uint32Value as UInt32:
            try container.encode(uint32Value)
        case let uint64Value as UInt64:
            try container.encode(uint64Value)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case is [Any]:
            let jsonValueArray = codableArray ?? []
            try container.encode(jsonValueArray)
        case is [String: Any]:
            let jsonValueDictValue = codableDictionary ?? [:]
            try container.encode(jsonValueDictValue)
        default:
            break
        }
    }
}
