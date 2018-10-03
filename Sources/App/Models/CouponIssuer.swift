//
//  CouponIssuer.swift
//  App
//
//  Created by Riyad Shauk on 10/1/18.
//

import Authentication
import FluentSQLite
import Vapor

/// A registered couponIssuer, capable of owning todo items.
final class CouponIssuer: SQLiteModel {
    /// CouponIssuer's unique identifier.
    /// Can be `nil` if the couponIssuer has not been saved yet.
    var id: Int?
    
    /// CouponIssuer's full name.
    var name: String
    
    /// BCrypt hash of the couponIssuer's password.
    var passwordHash: String
    
    /// Creates a new `CouponIssuer`.
    init(id: Int? = nil, name: String, passwordHash: String) {
        self.id = id
        self.name = "CouponIssuer"
        self.passwordHash = passwordHash
    }
}

/// Allows couponIssuers to be verified by basic / password auth middleware.
extension CouponIssuer: PasswordAuthenticatable {
    /// See `PasswordAuthenticatable`.
    static var usernameKey: WritableKeyPath<CouponIssuer, String> {
        return \.name
    }
    
    /// See `PasswordAuthenticatable`.
    static var passwordKey: WritableKeyPath<CouponIssuer, String> {
        return \.passwordHash
    }
}

/// Allows couponIssuers to be verified by bearer / token auth middleware.
extension CouponIssuer: TokenAuthenticatable {
    /// See `TokenAuthenticatable`.
    typealias TokenType = CouponIssuerToken
}

/// Allows `CouponIssuer` to be used as a Fluent migration.
extension CouponIssuer: Migration {
    /// See `Migration`.
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(CouponIssuer.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.passwordHash)
            builder.unique(on: \.name) // ensures only one CouponIssuer can be created (where it's name is simply "CouponIssuer")
        }
    }
}

/// Allows `CouponIssuer` to be encoded to and decoded from HTTP messages.
extension CouponIssuer: Content { }

/// Allows `CouponIssuer` to be used as a dynamic parameter in route definitions.
extension CouponIssuer: Parameter { }
