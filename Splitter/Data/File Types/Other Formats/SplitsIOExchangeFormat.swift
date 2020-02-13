//
//  SplitsIOExchangeFormat.swift
//  SplitsIOExchangeFramework
//
//  Created by Michael Berk on 1/24/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

// MARK: - SplitsIOExchangeFormat

/** Handles the data from generic splits.io JSON files (otherwise known as the splits.io Exchange Format)

This class was generated from JSON Schema using quicktype, do not modify it directly.

 To parse the JSON, do:

	`let splitsIOExchangeFormat = try SplitsIOExchangeFormat(json)`

*/
public class SplitsIOExchangeFormat: Codable {
    public let schemaVersion: String?
    public let links: SplitsIOExchangeFormatLinks?
    public let timer: SplitsIOTimer?
    public let attempts: SplitsIOAttempts?
    public let game, category: SplitsIOCategory?
    public let runners: [JSONAny]?
    public let segments: [SplitsIOSegment]?

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case links, timer, attempts, game, category, runners, segments
    }

   public init(schemaVersion: String?, links: SplitsIOExchangeFormatLinks?, timer: SplitsIOTimer?, attempts: SplitsIOAttempts?, game: SplitsIOCategory?, category: SplitsIOCategory?, runners: [JSONAny]?, segments: [SplitsIOSegment]?) {
        self.schemaVersion = schemaVersion
        self.links = links
        self.timer = timer
        self.attempts = attempts
        self.game = game
        self.category = category
        self.runners = runners
        self.segments = segments
    }
}

// MARK: SplitsIOExchangeFormat convenience initializers and mutators

extension SplitsIOExchangeFormat {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(SplitsIOExchangeFormat.self, from: data)
        self.init(schemaVersion: me.schemaVersion, links: me.links, timer: me.timer, attempts: me.attempts, game: me.game, category: me.category, runners: me.runners, segments: me.segments)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        schemaVersion: String?? = nil,
        links: SplitsIOExchangeFormatLinks?? = nil,
        timer: SplitsIOTimer?? = nil,
        attempts: SplitsIOAttempts?? = nil,
        game: SplitsIOCategory?? = nil,
        category: SplitsIOCategory?? = nil,
        runners: [JSONAny]?? = nil,
        segments: [SplitsIOSegment]?? = nil
    ) -> SplitsIOExchangeFormat {
        return SplitsIOExchangeFormat(
            schemaVersion: schemaVersion ?? self.schemaVersion,
            links: links ?? self.links,
            timer: timer ?? self.timer,
            attempts: attempts ?? self.attempts,
            game: game ?? self.game,
            category: category ?? self.category,
            runners: runners ?? self.runners,
            segments: segments ?? self.segments
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SplitsIOAttempts
public class SplitsIOAttempts: Codable {
   public  let total: Int?
   public  let histories: [JSONAny]?

    public init(total: Int?, histories: [JSONAny]?) {
        self.total = total
        self.histories = histories
    }
}

// MARK: SplitsIOAttempts convenience initializers and mutators

extension SplitsIOAttempts {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(SplitsIOAttempts.self, from: data)
        self.init(total: me.total, histories: me.histories)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        total: Int?? = nil,
        histories: [JSONAny]?? = nil
    ) -> SplitsIOAttempts {
        return SplitsIOAttempts(
            total: total ?? self.total,
            histories: histories ?? self.histories
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SplitsIOCategory
public class SplitsIOCategory: Codable {
   public  let longname, shortname: String?
   public  let links: SplitsIOCategoryLinks?

    public init(longname: String?, shortname: String?, links: SplitsIOCategoryLinks?) {
        self.longname = longname
        self.shortname = shortname
        self.links = links
    }
}

// MARK: SplitsIOCategory convenience initializers and mutators

extension SplitsIOCategory {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(SplitsIOCategory.self, from: data)
        self.init(longname: me.longname, shortname: me.shortname, links: me.links)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        longname: String?? = nil,
        shortname: String?? = nil,
        links: SplitsIOCategoryLinks?? = nil
    ) -> SplitsIOCategory {
        return SplitsIOCategory(
            longname: longname ?? self.longname,
            shortname: shortname ?? self.shortname,
            links: links ?? self.links
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SplitsIOCategoryLinks
public class SplitsIOCategoryLinks: Codable {
   public let splitsioID: String?

    init(splitsioID: String?) {
        self.splitsioID = splitsioID
    }
}

// MARK: SplitsIOCategoryLinks convenience initializers and mutators

extension SplitsIOCategoryLinks {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(SplitsIOCategoryLinks.self, from: data)
        self.init(splitsioID: me.splitsioID)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        splitsioID: String?? = nil
    ) -> SplitsIOCategoryLinks {
        return SplitsIOCategoryLinks(
            splitsioID: splitsioID ?? self.splitsioID
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SplitsIOExchangeFormatLinks
public class SplitsIOExchangeFormatLinks: Codable {
	
    public init() {
    }
}

// MARK: SplitsIOExchangeFormatLinks convenience initializers and mutators

extension SplitsIOExchangeFormatLinks {
    convenience init(data: Data) throws {
        let _ = try newJSONDecoder().decode(SplitsIOExchangeFormatLinks.self, from: data)
        self.init()
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
    ) -> SplitsIOExchangeFormatLinks {
        return SplitsIOExchangeFormatLinks(
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SplitsIOSegment
public class SplitsIOSegment: Codable {
	public let name: String?
	public let endedAt, bestDuration: SplitsIOBestDuration?
    public let isSkipped: Bool?
    public let histories: [JSONAny]?

   public init(name: String?, endedAt: SplitsIOBestDuration?, bestDuration: SplitsIOBestDuration?, isSkipped: Bool?, histories: [JSONAny]?) {
        self.name = name
        self.endedAt = endedAt
        self.bestDuration = bestDuration
        self.isSkipped = isSkipped
        self.histories = histories
    }
}

// MARK: SplitsIOSegment convenience initializers and mutators

extension SplitsIOSegment {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(SplitsIOSegment.self, from: data)
        self.init(name: me.name, endedAt: me.endedAt, bestDuration: me.bestDuration, isSkipped: me.isSkipped, histories: me.histories)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String?? = nil,
        endedAt: SplitsIOBestDuration?? = nil,
        bestDuration: SplitsIOBestDuration?? = nil,
        isSkipped: Bool?? = nil,
        histories: [JSONAny]?? = nil
    ) -> SplitsIOSegment {
        return SplitsIOSegment(
            name: name ?? self.name,
            endedAt: endedAt ?? self.endedAt,
            bestDuration: bestDuration ?? self.bestDuration,
            isSkipped: isSkipped ?? self.isSkipped,
            histories: histories ?? self.histories
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SplitsIOBestDuration
public class SplitsIOBestDuration: Codable {
   public let realtimeMS, gametimeMS: Int?

    public init(realtimeMS: Int?, gametimeMS: Int?) {
        self.realtimeMS = realtimeMS
        self.gametimeMS = gametimeMS
    }
}

// MARK: SplitsIOBestDuration convenience initializers and mutators

extension SplitsIOBestDuration {
    public convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(SplitsIOBestDuration.self, from: data)
        self.init(realtimeMS: me.realtimeMS, gametimeMS: me.gametimeMS)
    }

    public convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

   public convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        realtimeMS: Int?? = nil,
        gametimeMS: Int?? = nil
    ) -> SplitsIOBestDuration {
        return SplitsIOBestDuration(
            realtimeMS: realtimeMS ?? self.realtimeMS,
            gametimeMS: gametimeMS ?? self.gametimeMS
        )
    }

    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SplitsIOTimer
public class SplitsIOTimer: Codable {
    public let shortname, longname: String?
    public let website: String?
    public let version: String?

   public init(shortname: String?, longname: String?, website: String?, version: String?) {
        self.shortname = shortname
        self.longname = longname
        self.website = website
        self.version = version
    }
}

// MARK: SplitsIOTimer convenience initializers and mutators

extension SplitsIOTimer {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(SplitsIOTimer.self, from: data)
        self.init(shortname: me.shortname, longname: me.longname, website: me.website, version: me.version)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        shortname: String?? = nil,
        longname: String?? = nil,
        website: String?? = nil,
        version: String?? = nil
    ) -> SplitsIOTimer {
        return SplitsIOTimer(
            shortname: shortname ?? self.shortname,
            longname: longname ?? self.longname,
            website: website ?? self.website,
            version: version ?? self.version
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

public func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

public func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - Encode/decode helpers

public class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

public class JSONCodingKey: CodingKey {
    let key: String

	required public init?(intValue: Int) {
        return nil
    }

	required public init?(stringValue: String) {
        key = stringValue
    }

	public var intValue: Int? {
        return nil
    }

	public var stringValue: String {
        return key
    }
}

public class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}
