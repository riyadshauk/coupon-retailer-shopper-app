//
//  ShopperToken.swift
//  App
//
//  Created by Riyad Shauk on 10/1/18.
//

import Authentication
import Crypto
import FluentSQLite
import Vapor

/// An ephermal authentication token that identifies a registered shopper.
final class ShopperToken: SQLiteModel {
    /// Creates a new `ShopperToken` for a given shopper.
    static func create(shopperID: Shopper.ID) throws -> ShopperToken {
        // generate a random 128-bit, base64-encoded string.
        let string = try CryptoRandom().generateData(count: 16).base64EncodedString()
        // init a new `ShopperToken` from that string.
        return .init(string: string, shopperID: shopperID)
    }
    
    /// See `Model`.
    static var deletedAtKey: TimestampKey? { return \.expiresAt }
    
    /// ShopperToken's unique identifier.
    var id: Int?
    
    /// Unique token string.
    var string: String
    
    /// Reference to shopper that owns this token.
    var shopperID: Shopper.ID
    
    /// Expiration date. Token will no longer be valid after this point.
    var expiresAt: Date?
    
    /// Creates a new `ShopperToken`.
    init(id: Int? = nil, string: String, shopperID: Shopper.ID) {
        self.id = id
        self.string = string
        // set token to expire after 5 hours
        self.expiresAt = Date.init(timeInterval: 60 * 60 * 5, since: .init())
        self.shopperID = shopperID
    }
}

extension ShopperToken {
    /// Fluent relation to the shopper that owns this token.
    var shopper: Parent<ShopperToken, Shopper> {
        return parent(\.shopperID)
    }
}

/// Allows this model to be used as a TokenAuthenticatable's token.
extension ShopperToken: Token {
    /// See `Token`.
    typealias UserType = Shopper
    
    /// See `Token`.
    static var tokenKey: WritableKeyPath<ShopperToken, String> {
        return \.string
    }
    
    /// See `Token`.
    static var userIDKey: WritableKeyPath<ShopperToken, Shopper.ID> {
        return \.shopperID
    }
}

/// Allows `ShopperToken` to be used as a Fluent migration.
extension ShopperToken: Migration {
    /// See `Migration`.
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(ShopperToken.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.string)
            builder.field(for: \.shopperID)
            builder.field(for: \.expiresAt)
            builder.reference(from: \.shopperID, to: \Shopper.id)
        }
    }
}

/// Allows `ShopperToken` to be encoded to and decoded from HTTP messages.
extension ShopperToken: Content { }

/// Allows `ShopperToken` to be used as a dynamic parameter in route definitions.
extension ShopperToken: Parameter { }
