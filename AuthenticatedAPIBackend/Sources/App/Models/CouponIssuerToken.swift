//
//  CouponIssuerToken.swift
//  App
//
//  Created by Riyad Shauk on 10/1/18.
//

import Authentication
import Crypto
import FluentSQLite
import Vapor

/// An ephermal authentication token that identifies a registered couponIssuer.
final class CouponIssuerToken: SQLiteModel {
    /// Creates a new `CouponIssuerToken` for a given couponIssuer.
    static func create(couponIssuerID: CouponIssuer.ID) throws -> CouponIssuerToken {
        // generate a random 128-bit, base64-encoded string.
        let string = try CryptoRandom().generateData(count: 16).base64EncodedString()
        // init a new `CouponIssuerToken` from that string.
        return .init(string: string, couponIssuerID: couponIssuerID)
    }
    
    /// See `Model`.
    static var deletedAtKey: TimestampKey? { return \.expiresAt }
    
    /// CouponIssuerToken's unique identifier.
    var id: Int?
    
    /// Unique token string.
    var string: String
    
    /// Reference to couponIssuer that owns this token.
    var couponIssuerID: CouponIssuer.ID
    
    /// Expiration date. Token will no longer be valid after this point.
    var expiresAt: Date?
    
    /// Creates a new `CouponIssuerToken`.
    init(id: Int? = nil, string: String, couponIssuerID: CouponIssuer.ID) {
        self.id = id
        self.string = string
        // set token to expire after 5 hours
        self.expiresAt = Date.init(timeInterval: 60 * 60 * 5, since: .init())
        self.couponIssuerID = couponIssuerID
    }
}

extension CouponIssuerToken {
    /// Fluent relation to the couponIssuer that owns this token.
    var couponIssuer: Parent<CouponIssuerToken, CouponIssuer> {
        return parent(\.couponIssuerID)
    }
}

/// Allows this model to be used as a TokenAuthenticatable's token.
extension CouponIssuerToken: Token {
    /// See `Token`.
    typealias UserType = CouponIssuer
    
    /// See `Token`.
    static var tokenKey: WritableKeyPath<CouponIssuerToken, String> {
        return \.string
    }
    
    /// See `Token`.
    static var userIDKey: WritableKeyPath<CouponIssuerToken, CouponIssuer.ID> {
        return \.couponIssuerID
    }
}

/// Allows `CouponIssuerToken` to be used as a Fluent migration.
extension CouponIssuerToken: Migration {
    /// See `Migration`.
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(CouponIssuerToken.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.string)
            builder.field(for: \.couponIssuerID)
            builder.field(for: \.expiresAt)
            builder.reference(from: \.couponIssuerID, to: \CouponIssuer.id)
        }
    }
}

/// Allows `CouponIssuerToken` to be encoded to and decoded from HTTP messages.
extension CouponIssuerToken: Content { }

/// Allows `CouponIssuerToken` to be used as a dynamic parameter in route definitions.
extension CouponIssuerToken: Parameter { }
