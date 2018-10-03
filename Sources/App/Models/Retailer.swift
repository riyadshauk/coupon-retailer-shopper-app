//
//  Retailer.swift
//  App
//
//  Created by Riyad Shauk on 10/1/18.
//

import Authentication
import FluentSQLite
import Vapor

/// A registered retailer, capable of owning todo items.
final class Retailer: SQLiteModel {
    /// Retailer's unique identifier.
    /// Can be `nil` if the retailer has not been saved yet.
    var id: Int?
    
    /// Retailer's full name.
    var name: String
    
    /// Retailer's email address.
    var email: String
    
    /// BCrypt hash of the retailer's password.
    var passwordHash: String
    
    /// Creates a new `Retailer`.
    init(id: Int? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
}

/// Allows retailers to be verified by basic / password auth middleware.
extension Retailer: PasswordAuthenticatable {
    /// See `PasswordAuthenticatable`.
    static var usernameKey: WritableKeyPath<Retailer, String> {
        return \.email
    }
    
    /// See `PasswordAuthenticatable`.
    static var passwordKey: WritableKeyPath<Retailer, String> {
        return \.passwordHash
    }
}

/// Allows retailers to be verified by bearer / token auth middleware.
extension Retailer: TokenAuthenticatable {
    /// See `TokenAuthenticatable`.
    typealias TokenType = RetailerToken
}

/// Allows `Retailer` to be used as a Fluent migration.
extension Retailer: Migration {
    /// See `Migration`.
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Retailer.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.email)
            builder.field(for: \.passwordHash)
            builder.unique(on: \.email)
        }
    }
}

/// Allows `Retailer` to be encoded to and decoded from HTTP messages.
extension Retailer: Content { }

/// Allows `Retailer` to be used as a dynamic parameter in route definitions.
extension Retailer: Parameter { }
