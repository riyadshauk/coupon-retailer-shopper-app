//
//  RetailerToken.swift
//  App
//
//  Created by Riyad Shauk on 10/1/18.
//

import Authentication
import Crypto
import FluentSQLite
import Vapor

/// An ephermal authentication token that identifies a registered retailer.
final class RetailerToken: SQLiteModel {
    /// Creates a new `RetailerToken` for a given retailer.
    static func create(retailerID: Retailer.ID) throws -> RetailerToken {
        // generate a random 128-bit, base64-encoded string.
        let string = try CryptoRandom().generateData(count: 16).base64EncodedString()
        // init a new `RetailerToken` from that string.
        return .init(string: string, retailerID: retailerID)
    }
    
    /// See `Model`.
    static var deletedAtKey: TimestampKey? { return \.expiresAt }
    
    /// RetailerToken's unique identifier.
    var id: Int?
    
    /// Unique token string.
    var string: String
    
    /// Reference to retailer that owns this token.
    var retailerID: Retailer.ID
    
    /// Expiration date. Token will no longer be valid after this point.
    var expiresAt: Date?
    
    /// Creates a new `RetailerToken`.
    init(id: Int? = nil, string: String, retailerID: Retailer.ID) {
        self.id = id
        self.string = string
        // set token to expire after 5 hours
        self.expiresAt = Date.init(timeInterval: 60 * 60 * 5, since: .init())
        self.retailerID = retailerID
    }
}

extension RetailerToken {
    /// Fluent relation to the retailer that owns this token.
    var retailer: Parent<RetailerToken, Retailer> {
        return parent(\.retailerID)
    }
}

/// Allows this model to be used as a TokenAuthenticatable's token.
extension RetailerToken: Token {
    /// See `Token`.
    typealias UserType = Retailer
    
    /// See `Token`.
    static var tokenKey: WritableKeyPath<RetailerToken, String> {
        return \.string
    }
    
    /// See `Token`.
    static var userIDKey: WritableKeyPath<RetailerToken, Retailer.ID> {
        return \.retailerID
    }
}

/// Allows `RetailerToken` to be used as a Fluent migration.
extension RetailerToken: Migration {
    /// See `Migration`.
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(RetailerToken.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.string)
            builder.field(for: \.retailerID)
            builder.field(for: \.expiresAt)
            builder.reference(from: \.retailerID, to: \Retailer.id)
        }
    }
}

/// Allows `RetailerToken` to be encoded to and decoded from HTTP messages.
extension RetailerToken: Content { }

/// Allows `RetailerToken` to be used as a dynamic parameter in route definitions.
extension RetailerToken: Parameter { }
